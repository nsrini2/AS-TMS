require_cubeless_engine_file(:controller, :application_controller)

class ApplicationController

  before_filter :active_users
  
  helper :all
  
  def active_users
    @active_users ||= Profile.active_users_count
  end
  
end