require_cubeless_engine_file(:controller, :application_controller)

class ApplicationController

  before_filter :active_users
  
  helper :all
  
  def active_users
    @active_users ||= Profile.active_users_count
  end
  
  private
  def render_appropriate_layout
    if !current_profile
      render :layout => 'public' and return
    end    
  end
  
  def public_or_private_layout
    if !current_profile
      'public'
    else
      ApplicationController.read_inheritable_attribute(:layout)
    end
  end
  
end
