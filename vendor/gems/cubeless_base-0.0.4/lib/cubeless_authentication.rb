module CubelessAuthentication

  def sso_authenticate
    # dont use sso if logged in as a 'celebrity' user (non-sso user) - or if acting as a user in backdoor mode
    if @@header_sso_id_key
      auth_header_sso if !currently_non_sso_user? && !BackdoorController.backdoor_active?(session)
    elsif BackdoorController.enabled? && !logged_in? 
      self.current_user = User.find_by_sso_id(ENV['USERNAME'].downcase) if ENV['USERNAME']
    end
  end

  def require_auth
    if logged_in?
      if require_password_change?
        return respond_change_password unless params[:action] == "change_password"
      end
      return true
    end
    return respond_not_authorized if @@header_sso_id_key
    store_location
    return redirect_to(SsoController.login_url) if SsoController.configured?
    redirect_to :controller => '/account', :action => 'login'
  end
  
  # @@api_enabled = Config[:api_enabled]
  def require_api_key
    return render(:text => "API Disabled") unless Config[:api_enabled] # @@api_enabled
    login_from_api_key
    return true if logged_in?
    render :text => "Access Denied"
  end

  @@header_sso_id_key = Config[:header_sso_id_key]
  if @@header_sso_id_key
    @@header_sso_secret_key = Config[:header_sso_secret_key]
    @@header_sso_secret_value = Config[:header_sso_secret_value]
  end

  def require_password_change?
    return if current_profile.has_role?(Role::CubelessAdmin)
    duration_seconds = current_profile.has_role?(Role::ShadyAdmin, Role::ContentAdmin, Role::ShadyAdmin, Role::UserAdmin, Role::AwardsAdmin, Role::SponsorAdmin) ? Config['user.pwd.duration.admin'] : Config['user.pwd.duration.user']
    duration_seconds && current_user.uses_login_pass? && Time.now > current_user.password_changed_at + duration_seconds
  end

  def respond_change_password
    add_to_notices "Your password has expired. Please set a new password"
    redirect_to :controller => '/account', :action => 'change_password'
  end

  def respond_not_authorized
    if params[:format] == "xml"
      render :text => "Access Denied" and return
    else
      return redirect_to(current_profile ? profile_path(current_profile) : login_account_path)
    end
  end

  # def admin_required
  #   return true if current_profile.has_role?(Role::ShadyAdmin)
  #   audit_event(:unauthorized_admin_access)
  #   @error = "Hey there bud!  Only Administrators can access that page."
  #   render :template => 'application/error'
  # end

  # def is_admin?
  #   logged_in? && current_profile.has_role?(Role::ShadyAdmin)
  # end

  def current_profile
    @current_profile ||= logged_in? ? Profile.find_by_user_id(current_user.id) : false
  end

  def verify_session
    return unless Config['session.lifetime']
    if (session[:expires_at] && session[:expires_at] < Time.now)
      expire_session
    else
      session[:expires_at] = Time.now + Config['session.lifetime']
    end
  end

  def verify_password
    expire_session if logged_in? && current_user.uses_login_pass? && current_user.crypted_password.blank?
  end

  def self.included(base)
    base.send :helper_method, :current_profile
  end

  def expire_session
    current_user = nil
    cookies.delete :auth_token
    reset_session
  end
  
  private

  def auth_header_sso
    if @@header_sso_secret_key && @@header_sso_secret_value!=request.headers[@@header_sso_secret_key]
        self.current_user = nil
        return
    end
    sso_id = request_env(@@header_sso_id_key)
    self.current_user = User.find(:first,:conditions => ['sso_id=?',sso_id]) unless logged_in? and sso_id==self.current_user.sso_id
  end
  
  def currently_non_sso_user?
    logged_in? && current_user.sso_id.blank?
  end

  def request_env(key)
    s = request.env[key]
    s.is_a?(StringIO) ? s.string : s
  end

end
