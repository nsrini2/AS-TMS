require_cubeless_engine_file(:controller, :application_controller)

class ApplicationController
  before_filter :active_users, :set_stats, :identify
  
  helper :all
  
  layout :resolve_layout
  
  def active_users
    @active_users ||= Profile.active_users_count
  end
  
  private  
  def resolve_layout
    if current_profile 
      '_application'
    else
      'public'
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
  
  #companies
  def current_company
    @company ||= current_profile.company
    if @company.nil?
      render :layout => false, :file => "/companies/channels"
      return
    end
    @company
  end
  
  helper_method :current_company
  
  #for facebook login
  def find_facebook_uid
    @oauth = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET)
    # user_facebook_session = @oauth.get_user_info_from_cookies(cookies)
    @facebook_uid = @oauth.get_user_from_cookies(cookies)
  end
  
  def facebook_graph
    # SSJ - if the website is unable to contact Facebook 
    # present registration form without pre-filled options
    begin
      @facebook_cookies ||= Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET).get_user_info_from_cookie(cookies)
      access_token = @facebook_cookies["access_token"]      
      graph = Koala::Facebook::GraphAPI.new(access_token)
      user_graph = graph.get_object("me")
    rescue 
      Rails.logger.debug $!
      nil
    end    
  end
  
  def set_stats
    if !current_profile
      @members = User.all.count
      @groups = Group.all.count
      @answers = Answer.all.count
    end  
  end
  
  def current_temp_user
    @current_temp_user ||=  if session[:temp_user] && !session[:temp_user].blank?
                              TempUser.find(session[:temp_user])
                            else
                              nil
                            end
  end
  def current_temp_user=(temp_user)
    session[:temp_user] = temp_user.id
    @current_temp_user = temp_user
  end
  
  helper_method :current_temp_user
  
  before_filter :check_current_temp_user, :except => [:logout]
  def check_current_temp_user
    # here session[:temp_user]
    # here current_temp_user

  end
  
  def identify
    Rails.logger.info "Controller: #{params[:controller]}"
    Rails.logger.info "Action: #{params[:action]}"
  end

  # if Rails.env.production?
  #   prepend_before_filter :staging_auth
  #   
  #   USER, PASSWORD = 'asdepre', '$^Br3!'
  # 
  #   def staging_auth
  #     authenticate_or_request_with_http_basic do |user, password|
  #       user == USER && password == PASSWORD
  #     end
  #   end
  # end
    
end
