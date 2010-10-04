# MM2
# I know this is kind of janky, but it will have to do until all of the cubeless engine in namespaced as such
# Without this require, this controller will completely overwrite the cubeless engine. It will NOT extend it.
require "#{Rails.root}/vendor/plugins/cubeless/app/controllers/profiles_controller"

class ProfilesController

  layout nil
  
  def hub    
    render :layout => nil
  end
  
end