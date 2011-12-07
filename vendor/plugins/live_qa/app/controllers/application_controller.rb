# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  private
  def find_chat
    @chat = Chat.find(params[:chat_id])
  end
  def find_chat_include_host
    @chat = Chat.find(params[:chat_id], :include => [:profile])
  end
  def find_topic
    @topic = Topic.find(params[:topic_id])
  end
end
