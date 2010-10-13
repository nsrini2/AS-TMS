# MM2
# I know this is kind of janky, but it will have to do until all of the cubeless engine in namespaced as such
# Without this require, this controller will completely overwrite the cubeless engine. It will NOT extend it.
require "#{Rails.root}/vendor/plugins/cubeless/app/controllers/application_controller"

class ApplicationController

  before_filter :active_users
  
  helper :all
  
  def active_users
    @active_users ||= Profile.active_users_count
  end
  
end