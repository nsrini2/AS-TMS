require_cubeless_engine_file(:controller, :application_controller)

class ApplicationController

  before_filter :active_users
  
  helper :all
  
  layout :public_or_private_layout
  
  def active_users
    @active_users ||= Profile.active_users_count
  end
  
  private  
  def public_or_private_layout
    if !current_profile
      'public'
    else
      '_application'
    end
  end
  
  # for live_qa
  def find_chat
    @chat = Chat.find(params[:chat_id])
  end
  def find_chat_include_host
    @chat = Chat.find(params[:chat_id], :include => [:profile, :topics])
  end
  def find_topic
    @topic = Topic.find(params[:topic_id])
  end
  
end
