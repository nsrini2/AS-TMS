require_cubeless_engine_file(:controller, :profiles_controller)

class ProfilesController
  skip_before_filter :require_terms_acceptance, :only => [:hub]
  helper :event_stream
  helper :watches
  
  def hub
    if params.member?('survey')
      current_user.survey_taken!
    end
    @widgets = {}
        
    # Add the default widget
    # @widgets["1"] = { :id => "1", :title => "Facebook Activity", :url=>"/profiles/my_widget", :internal => false }

    # Add the other content admin widgets
    w_idx = @widgets.size + 1
    Widget.all.each do |w|
      @widgets[w_idx.to_s] = { :id => w_idx, :title => w.title, :url => widget_path(w), :internal => false, :hide_settings => true }
      w_idx += 1
    end
    
    # MM2: No longer using followings
    # MM2: If you do bring them back, the current_profile.watch_events is SUPER SLOW!
    # @followings = [] # current_profile.watch_events(watch_filters({:order => 'created_at desc'}))
    
    @system_announcement = SystemAnnouncement.get_if_active    
    @random_marketing_message = MarketingMessage.random_active_message

    @profile_stats = current_profile.stats    
    @profile_stats[:karma_points] = current_profile.karma_points
    @profile_stats[:groups] = current_profile.groups.count
    @profile_stats[:blog_posts] = current_profile.blog_posts.count
    
    # @questions_referred_to_me = current_profile.questions_referred_to_me
    @latest_question = Question.last
    
    # TODO: Organized by the last ones I participated in
    @groups = current_profile.groups.find(:all, :order => "rand()", :limit => 3)
    # @groups = @groups[@groups.size-3..@groups.size-1].to_a.reverse
    @deals = Offer.not_in_folder(current_user.id).random(3)
    # ids = @deals.map { |d| d.id }
    # fail ids.inspect

    @blog_posts = BlogPost.publicized.limit(2)
    @news_posts = News.top_posts(3)
    # @news_posts = News.blog_posts.where("text LIKE ?", "%img%").limit(3)
    
    
    # @blog_posts = BlogPost.joins(:blog).where(["blogs.owner_type <> ?", "Company"]).order("rand()").limit(2)
    

    # TODO: Make into one query
    @messages = [current_profile.notes.recent, current_profile.sent_notes.recent].flatten.sort_by(&:created_at).reverse
    
    @events = ActivityStreamEvent.find_summary(:all, :page => params[:page])
    @activity_stream_message = ActivityStreamMessage.active.find(:all, :order => "rand()", :limit => 1).first
    
    # For status or question creation
    @status = Status.new
    @question = Question.new
      
    @terms_and_conditions = TermsAndConditions.get.content unless current_user.terms_accepted
  end
  
  def badges
    
  end
  
end