class PostsController < ApplicationController
  before_filter :find_chat
  before_filter :find_topic
  before_filter :verify_on_air
  
  def create
    Participant.set_status(@chat, current_profile.id, "contributed")

    @post = @topic.posts.new(params[:post])
    if @post.save
      render :text => @post.to_json(:methods => :display_name)
    # else
    #    render :text => "{ error: 'unalbe to save post. #{@post.errors}' }"  
    end  
  end
  
  def poll
    since_id = params[:since_id]
    if since_id.blank? || since_id.to_i == 0
      @posts = @topic.posts
    else
      stale_newest_post = Post.find(params[:since_id])
      @posts = @topic.posts.find(:all, :conditions => ["id > ?", stale_newest_post.id])
    end
    
    respond_to do |format|
      format.html {
        render(:partial => "/chats/posts", :locals => { :posts => @posts })
      }
      format.json {
        render :text => @posts.to_json(:methods => Post.json_methods)
      }
    
    end
  end
  
  private
  def verify_on_air
    unless @chat.on_air?
      render :text => "" and return
    end
  end
  
end