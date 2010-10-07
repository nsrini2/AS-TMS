# MM2
# I know this is kind of janky, but it will have to do until all of the cubeless engine in namespaced as such
# Without this require, this controller will completely overwrite the cubeless engine. It will NOT extend it.
require "#{Rails.root}/vendor/plugins/cubeless/app/controllers/profiles_controller"

class ProfilesController

  layout nil
  
  def hub    
    @system_announcement = SystemAnnouncement.get_if_active

    @profile_stats = current_profile.stats    
    @profile_stats[:karma_points] = current_profile.karma_points
    @profile_stats[:groups] = current_profile.groups.count
    @profile_stats[:blog_posts] = current_profile.blog_posts.count
    
    @questions_referred_to_me = current_profile.questions_referred_to_me
    @groups = current_profile.groups
    
    @messages = current_profile.notes

    render :layout => nil
  end
  
end