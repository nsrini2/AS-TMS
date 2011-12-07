class BackdoorController < ApplicationController
  
  skip_before_filter :require_auth
  skip_before_filter :verify_authenticity_token
  
  @@backdoor_mode_enabled = Config[:backdoor_mode]
  
  def self.enabled?
    @@backdoor_mode_enabled
  end
  
  def self.backdoor_active?(session)
    @@backdoor_mode_enabled && session[:backdoor_user_override]
  end  
  
  def show
    raise unless BackdoorController.enabled?
    user = nil
    case
      when !params[:login].blank?
        user = User.find_by_login(params[:login])
      when !params[:sso_id].blank?
        user = User.find_by_sso_id(params[:sso_id])
      when !params[:profile_id].blank?
        user = Profile.find(params[:profile_id].to_i).user
    end
    if user
      self.current_user = user
      if logged_in?
        session[:backdoor_user_override] = true
        return redirect_to('/')
      end
    end
    render :action => 'show' # since we alias create
  end
  
  alias_method :create, :show
  
end