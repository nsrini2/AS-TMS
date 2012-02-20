class ChatsController < ApplicationController
  before_filter :find_chat, :only => [:show, :rsvp, :close, :participants, :start_message]
  before_filter :editable?, :only => [:edit, :update, :destroy]
  before_filter :apply_start_time, :only => [:create, :update] 
  before_filter :set_durations
  
  # GET /chats
  def index
    limit_current_chats = 7
    limit_past_chats = 3
    @live_chats = Chat.live
    @upcoming_chats = Chat.upcoming
    @past_chats = Chat.past
    if !params[:all_current] && @upcoming_chats.size > limit_current_chats
      @upcoming_chats = @upcoming_chats.first(limit_current_chats)
      @more_chats = true
    end
    if !params[:all_past] && @past_chats.size > limit_past_chats
      @past_chats = @past_chats.first(limit_past_chats)
      @more_past_chats = true
    end
  end
  
  # GET /chats/new
  def new
    @chat = Chat.new(:host_id => current_profile.id, :start_at => Time.now )
  end
  
  # POST /chats
  def create
    @chat = Chat.new(params[:chat])
    if params[:asset]
      @chat.chat_photo = ChatPhoto.new(params[:asset])
    end
    if @chat.save
      # once created route to INDEX
      redirect_to(:action => @chat.id)
    else 
      # validation ERRORS
      flash[:errors] = @chat.errors       
      render :action => "new" 
    end
  end
  
  # GET /chats/1/edit
  def edit
    @participants = @chat.participants
    #SSJ offset is set to Central Time, NOT GMT
    @hour = @chat.start_at.hour.to_s
    @minutes = @chat.start_at.min.to_s
    @zone = 'Central Time (US & Canada)'
  end
  
  # GET /chats/close/1
  def close
    unless @chat.close(current_profile)
      flash[:notice]= "Unable to close #{@chat.title}.\n You must be the host to close a chat"
    end  
    redirect_to :action => "index"
  end
  
  # PUT /chats/1
  def update
    
    org_chat = Chat.new(@chat.attributes)
    if params[:asset]
      @chat.chat_photo = ChatPhoto.new(params[:asset])
    end
    if @chat.update_attributes(params[:chat])
      flash[:notice] = 'Job was successfully updated.'
      if @chat.change_notification_trigger?(org_chat) || params[:send_notification]
        flash[:notice] << "\nEmail notifications will be sent to those attending."
        Chat.delay.send_chat_update_emails(@chat.id)
      end  
      redirect_to(@chat)
    else
      flash[:errors] = @chat.errors
      render :action => "edit"
    end
  end
  
  # DELETE /chats/:id
  def destroy
    if @chat.destroy
      flash[:notice] = "Chat removed!"
      redirect_to(:action => :index)
    else
      flash[:notice] = @chat.errors
      render(:action => 'show')
    end    
  end
  
  # GET /chats/:id
  def show
    @topics = @chat.topics
    @attendees = @chat.attendees
    @rsvps = @chat.rsvps
    
    # MM2: Currently grabbed in view. May need to pull back out for performance
    # @newest_topic_id = @chat.newest_topic_id
    # @newest_post_id = @chat.newest_post_id
    
    if params[:start] && @chat.host == current_profile
      @chat.started_at = Time.now() 
      unless @chat.save 
        render(:text => "Unable to start Chat, please refresh and try again.") and return
      end  
    end 
           
    if @chat.on_air?
      Participant.set_status(@chat, current_profile.id, "attended")
      render(:action => "live")
    end
    
    if @chat.closed?
      if params[:topic]
        @requested_topic = params[:topic]
      else
        @requested_topic = @chat.topics.first
      end  
      render(:action => "closed")
    end  
  end
  
  def rsvp
    if Participant.set_status(@chat, current_profile.id, params[:status])      
      link = view_context.link_to_rsvp(@chat)
      render(:text => link)
      # send confirmation/cancelation email
      participant = @chat.participants.find_by_profile_id(current_profile.id)
      Rails.logger.info "default_url_options[:host] has been set to: " + request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}") 
      server_host = request.protocol + request.domain + (request.port.nil? ? '' : ":#{request.port}")
      Notifier.deliver_live_qa_rsvp(participant, @chat, server_host)
    else
      render(:text => "Error saving RSVP change -- Please refresh this page")
    end  
  end
  
  def toggle_presenter
    participant = Participant.find(params[:id])
    participant.toggle_presenter
    render :text => participant.to_json
  end
  
  # GET /chats/1/participants
  def participants
    @attendees = @chat.attendees
    
    render :partial => "/chats/chat_participants", :locals => { :attendees => @attendees }
  end
  
  #GET /chats/1/start_message
  def start_message    
    render :text => @chat.start_message
  end
  
private

  def editable?
    find_chat
    errors = []
    errors << "Unable to edit a chat that is On The Air." if @chat.on_air?
    errors << "Unable to edit a chat that is Closed." if @chat.closed?
    errors << "Unable to edit a chat unless you are the host." unless @chat.host?(current_profile)
    
    if errors.size > 0   
      flash[:notice] = errors.join("\n")
      render(:action => 'show')
    end  
  end
  
  def find_chat
    render :text => "" and return if params[:id].blank?
    @chat = Chat.find(params[:id]) 
  end

  def apply_start_time
    # SSJ set the start time (this allows us to use 1 datetime field in lieu of a date and a time field) 
    params[:chat][:start_at] = Chat.compute_start_at_from_input(params[:chat][:start_at], params[:time] ) unless params[:chat][:start_at].blank?
  end

  def set_durations
    @durations = [{:label => '15 Mins', :value => 15}]
    @durations << {:label => '30 Mins', :value => 35}
    @durations << {:label => '45 Mins', :value => 45}
    @durations << {:label => '1 Hour', :value => 60}
    @durations << {:label => '1 Hour 15 Mins', :value => 75}
    @durations << {:label => '1 Hour 30 Mins', :value => 90}
    @durations << {:label => '1 Hour 45 Mins', :value => 105}
    @durations << {:label => '2 Hours(+)', :value => 120}
  end
  


end
