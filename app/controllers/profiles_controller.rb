# MM2
# I know this is kind of janky, but it will have to do until all of the cubeless engine in namespaced as such
# Without this require, this controller will completely overwrite the cubeless engine. It will NOT extend it.
require "#{Rails.root}/vendor/plugins/cubeless/app/controllers/profiles_controller"



class ProfilesController

  helper :event_stream
  
  def hub    
    @system_announcement = SystemAnnouncement.get_if_active

    @profile_stats = current_profile.stats    
    @profile_stats[:karma_points] = current_profile.karma_points
    @profile_stats[:groups] = current_profile.groups.count
    @profile_stats[:blog_posts] = current_profile.blog_posts.count
    
    @questions_referred_to_me = current_profile.questions_referred_to_me
    
    # TODO: Organized by the last ones I participated in
    @groups = current_profile.groups
    @groups = @groups[@groups.size-3..@groups.size-1].reverse


    # TODO: Clean this up...scraped from ExplorationsController.
    # Special options needed to ensure only personal posts or group posts that I can access show up
    blog_options = blog_filters
    ModelUtil.add_joins!(blog_options,"left join groups pg on pg.id = blogs.owner_id and blogs.owner_type = 'Group' and pg.group_type = 2")
    ModelUtil.add_conditions!(blog_options,"pg.id is null")
    @blog_posts = BlogPost.find(:all, blog_options)

    # TODO: Make into one query
    @messages = [current_profile.notes, current_profile.sent_notes].flatten.sort_by(&:created_at).reverse
    
    @events = ActivityStreamEvent.find_summary(:all,:limit => 7)
  end
  
end