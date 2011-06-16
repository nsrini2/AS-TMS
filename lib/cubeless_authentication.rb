require "#{Rails.root}/vendor/plugins/cubeless/lib/cubeless_authentication"

module CubelessAuthentication
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
    redirect_to :controller => '/account', :action => 'welcome'
  end
end  