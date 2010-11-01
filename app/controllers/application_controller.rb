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
  
end
