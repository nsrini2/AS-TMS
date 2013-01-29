class TopicsController < ApplicationController
  before_filter :find_chat, :except => [:destroy, :queued]
  before_filter :find_chat_include_host, :only => [:queued]
  
  def create
    @topic = @chat.topics.new(params[:topic]) 
    @topic.profile = current_profile
    
    if @topic.save
      if @chat.on_air?
        render(:partial => "/chats/queue_question", :locals => { :question => @topic, :ratable => true }) 
      else  
        render(:text => view_context.list_topic(@topic, current_profile))
      end  
    else
      render :text => "error"
    end
  end
  
  # DELETE /topics/:id
  def destroy
    topic = Topic.find(params[:id])
    if topic.destroy
      render(:text => "")
    else
      render(:text => "<li>Error deleting #{topic.title}, please refresh page and try again.</li>")
    end  
  end
  
  def poll
    if !params[:since_id].blank?
      stale_newest_topic = Topic.find(params[:since_id])
      @topics = @chat.topics.find(:all, :conditions => ["id > ?", stale_newest_topic.id])
    elsif params[:active_id]
      @json = { :new_active_topic => false }
      check_on_active
    else
      @topics = @chat.topics
      check_on_active
      @json = nil if @json.blank? # MM2...Meh. Caused by check_on_active creating @json
    end
    
    if @json
      render(:text => @json.to_json)
    else
      render(:partial => "/chats/topics", :locals => { :topics => @topics })
    end
  end
  
  # POST /topics/:id/discuss
  def discuss
    @topic = Topic.find(params[:id])
    
    @chat.activate_topic(@topic)
    
    render :text => @topic.to_json
  end
  
  # GET /topics/:id/discussion
  def discussion
    @topic = Topic.find(params[:id])
    
    render :partial => "/chats/present_discussion", :locals => { :chat => @chat, :question => @topic, :newest_post_id => @topic.newest_post_id }
  end
  
  # Microreviews
  # TODO: Abstract out to its own engine
  MICROREVIEW_API_KEY = "0dbe945749ad43ae05c4db108dfe0e4fae0a618a7d820504ab92195fc43df5c702aab92900a95d13485fcc04e7ab95fdb7ed931fa8121de5240330add7c434bc"
  def rate
    @topic = @chat.topics.find(params[:id]) 
    
    attributes = {  :item => { :external_type => Topic.mr_external_type, :external_id => @topic.id },
                    :microreview => { :quote => nil, 
                                      :rating => get_rating_from_params,
                                      :meta => { }.to_json },
                    :author => {  :external_id => current_profile.id, 
                                  :first_name => current_profile.first_name, 
                                  :last_name => current_profile.last_name, 
                                  :screen_name => current_profile.screen_name, 
                                  :email => current_profile.email },
                    :api_key => MICROREVIEW_API_KEY  }
    
    Microreview::Review.create(attributes)
    
    render :text => { :direction => params[:direction].to_s.titlecase, :errors => flash[:errors] }.to_json
  end
  def check_ratability
    ratable = true # Let's assume you can rate it unless proven otherwie
    
    @topic = @chat.topics.find(params[:id])
    
    attributes = {:external_type => Topic.mr_external_type, :external_id => @topic.id, 
                  :author_external_id => current_profile.id, :api_key => MICROREVIEW_API_KEY}
    
    reviews = Microreview::Review.find(attributes)
    if reviews && reviews.is_a?(Array) && !reviews.empty?
      ratable = false
    end 
    
    render :text => ratable
  end
  def rated_by_current_profile
    @topics = @chat.topics
    @rated_topics = []
    
    attributes = { :aggregate => true, :with_item => true,
                  :author_external_id => current_profile.id, :api_key => MICROREVIEW_API_KEY}
    
    reviews = Microreview::Review.find(attributes)
    if reviews && reviews.is_a?(Array) && !reviews.empty?
      reviews.each do |r|
        review = r["microreview"]
        item = review["item"]
        @rated_topics << @topics.detect{ |t| t.id == item["external_id"] } if item["external_type"] == Topic.mr_external_type
      end
    end 
    
    @topics = @rated_topics
    render :text => @topics.to_json
  end
  def queued
    @topics = @chat.topics.open
    @active_id = @chat.topics.active.last ? @chat.topics.active.last.id : ""
    
    @rated_topics = []
    
    # MM2: This gets very very inefficient over time
    # Too many votes without scoping on some external_id range :/
    attributes = { :with_item => true, :external_type => Topic.mr_external_type, :api_key => MICROREVIEW_API_KEY}
    
    # If the microreviews service is inaccessible, just don't include that piece
    begin
      if @chat.host == current_profile
        reviews = Microreview::Review.find(attributes)
        if reviews && reviews.is_a?(Array) && !reviews.empty?
          reviews.group_by{ |r| r["microreview"]["item"] }.each do |item, rs|
            topic_id = item["external_id"]
          
            topic = @topics.detect{ |t| t.id == topic_id }
          
            if topic
              topic.votes_up = rs.select{ |r| r["microreview"]["rating"].to_i == 5 }.size
              topic.votes_down = rs.select{ |r| r["microreview"]["rating"].to_i == 1 }.size
          
              @rated_topics << topic
            end
          end
        end      
      else
        attributes.merge!({ :aggregate => true, :author_external_id => current_profile.id })
    
        reviews = Microreview::Review.find(attributes)
        if reviews && reviews.is_a?(Array) && !reviews.empty?
          reviews.each do |r|
            review = r["microreview"]
            item = review["item"]
            @rated_topics << @topics.detect{ |t| t.id == item["external_id"] } if item["external_type"] == Topic.mr_external_type
          end
        end
      end
    rescue
      @rated_topics = []
    end
    
    render :partial => "/chats/chat_queue", :locals => 
								{ :chat => @chat, :topics => @topics, :newest_topic_id => @chat.newest_topic_id, :rated_topics => @rated_topics }
  end
  
  private
  def check_on_active
    @json ||= {}
    if @chat.topics.active.last && params[:active_id] != @chat.topics.active.last.id.to_s
      @json = {}
      @json[:new_active_topic] = true
      @topic = @chat.topics.active.last
      @json[:active_id] = @topic.id.to_s
      @json[:topic_discussion_url] = discussion_chat_topic_path(@chat, @topic)
    end
  end
  
  def get_rating_from_params
    params[:direction].to_s.downcase == "up" ? 5 : 1
  end
  
  
end