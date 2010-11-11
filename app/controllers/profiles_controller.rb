require_cubeless_engine_file(:controller, :profiles_controller)

class ProfilesController

  helper :event_stream
  helper :watches
  
  def hub
    @widgets = {}
        
    # Add the default widget
    @widgets["1"] = { :id => "1", :title => "Facebook Activity", :url=>"/profiles/my_widget", :internal => false }

    # Add the other content admin widgets
    w_idx = 2
    Widget.all.each do |w|
      @widgets[w_idx.to_s] = { :id => w_idx, :title => w.title, :url => widget_path(w), :internal => false, :hide_settings => true }
      w_idx += 1
    end
    
    
    # MM2: Please don't leave this as is. I'm talking to you Mark
    @profile = current_profile
    
    def init_watch_list
      @profile_watches = @profile.watches.find(:all, :conditions => "watchable_type='Profile'", :joins => "join profiles p on p.id=watches.watchable_id", :order => "p.screen_name")
      @group_watches = @profile.watches.find(:all, :conditions => "watchable_type='Group'", :joins => "join groups g on g.id=watches.watchable_id", :order => "g.name")
    end
    
    options = {:order => 'created_at desc'}
    #if params[:action]=='show'
    #  watch = Watch.find(params[:id])
    #  @filter_set = "Watch_#{watch.watchable_type.downcase}"
    #  options.merge!(:conditions => ['watch_events.watchable_type=? and watch_events.watchable_id=?',watch.watchable_type,watch.watchable_id])
    #end
    options.merge!(:conditions => "watch_events.watchable_type='Profile'") if params[:action]=='profiles'
    options.merge!(:conditions => "watch_events.watchable_type='Group'") if params[:action]=='groups'
    @events = @profile.watch_events(watch_filters(options))
    init_watch_list
    
    
    
    
    
    
    @system_announcement = SystemAnnouncement.get_if_active    
    @random_marketing_message = MarketingMessage.random_active_message

    @profile_stats = current_profile.stats    
    @profile_stats[:karma_points] = current_profile.karma_points
    @profile_stats[:groups] = current_profile.groups.count
    @profile_stats[:blog_posts] = current_profile.blog_posts.count
    
    @questions_referred_to_me = current_profile.questions_referred_to_me
    @latest_question = Question.last
    
    # TODO: Organized by the last ones I participated in
    @groups = current_profile.groups
    @groups = @groups[@groups.size-3..@groups.size-1].to_a.reverse


    # TODO: Clean this up...scraped from ExplorationsController.
    # Special options needed to ensure only personal posts or group posts that I can access show up
    blog_options = blog_filters
    ModelUtil.add_joins!(blog_options,"left join groups pg on pg.id = blogs.owner_id and blogs.owner_type = 'Group' and pg.group_type = 2")
    ModelUtil.add_conditions!(blog_options,"pg.id is null")
    @blog_posts = BlogPost.find(:all, blog_options)

    # TODO: Make into one query
    @messages = [current_profile.notes, current_profile.sent_notes].flatten.sort_by(&:created_at).reverse
    
    @events = ActivityStreamEvent.find_summary(:all,:limit => 7)
    
    # For status or question creation
    @status = Status.new
    @question = Question.new
  end
  
end