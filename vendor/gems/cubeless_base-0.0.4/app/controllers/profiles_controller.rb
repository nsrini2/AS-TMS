class ProfilesController < ApplicationController
  skip_before_filter :require_auth, :only => [:external, :external_widget]
  session :off, :only => [:external, :external_widget] #Done because requests from websource create new session files on every request
  before_filter :require_api_key, :only => [:external_widget, :external]
  before_filter :set_user_and_profile, :except => [:refresh_hot_topics_widget, :refresh_explore_profiles_widget, :karma_popup ]
  before_filter :check_profile_active_status, :except => [:refresh_hot_topics_widget, :refresh_explore_profiles_widget, :karma_popup, :completion_popup ]
  deny_access_for [:my_widget, :update_widget_sequence, :toggle_widget, :hub, :questions_asked, :questions_answers, :matched_questions, :more_matched_questions, :show, :external, :external_widget, :avatar_hover] => :sponsor_member

  def all_widgets
    widgets = {}
    
    # Add the default widget
    widgets["1"] = { :id => "1", :title => "My Widget", :url=>"/profiles/my_widget", :internal => false }
    
    # Add the other content admin widgets
    w_idx = 2
    Widget.all.each do |w|
      widgets[w_idx.to_s] = { :id => w_idx, :title => w.title, :url => widget_path(w), :internal => false, :hide_settings => true }
      w_idx += 1
    end
    
    # Add the cubeless widgets
    cubeless_w = [
      { :title => "Updates", :url=>"render_widget_home_status", :internal => true },
      { :title => "Ask a Question", :url=>"render_widget_home_ask_question", :internal => true },
      { :title => "Latest Community Question", :url=>"render_widget_newest_question", :internal => true },
      { :title => "Explore Profiles", :url=>"render_widget_home_explore_profiles", :internal => true, :refresh_url => "refresh_explore_profiles_widget_profiles_path" },
      { :title => "Recent Notes", :url=>"render_widget_home_notes", :internal => true },
      { :title => "Questions with New Answers", :url=>"render_widget_questions_with_new_answers @questions_with_new_answers", :internal => true },
      { :title => "Hot Topics", :url=>"render_widget_random_terms", :internal => true, :refresh_url => "refresh_hot_topics_widget_profiles_path" },
      { :title => "Referred Questions", :url=>"render_widget_referred_questions @referred_questions", :internal => true },
      { :title => "Watch List", :url=>"render_widget_watch_list @watched_questions", :internal => true },
      { :title => "Questions I Can Help Answer", :url=>"render_widget_matched_questions @matched_questions", :internal => true }
    ] 
    
    cubeless_w.each do |c|
      widgets[w_idx.to_s] = { :id => w_idx, :title => c[:title], :url => c[:url], :internal => c[:internal], :refresh_url => c[:refresh_url] }
      w_idx += 1
    end
    
    widgets
  end
  
  # TODO: Account for the square buttons
  def group_1_widgets
    @widgets ||= all_widgets
    
    g1 = []
    
    @widgets.each_with_index do |w, idx|
      g1 << idx.to_s if idx%2 == 1
    end
    
    g1.compact#.collect{ |w| w.to_s }
  end
  def group_2_widgets
    @widgets ||= all_widgets
    
    g2 = []
    
    @widgets.each_with_index do |w, idx|
      g2 << idx.to_s if idx%2 == 0
    end
    
    g2.compact#.collect{ |w| w.to_s }
  end  

  def my_widget
    if request.post? && (params[:url] || params[:restore_default])
      widget_config = @profile.widget_config ? eval(@profile.widget_config) : {}
      widget_config[:any_widget] = params[:url] if params[:url]
      widget_config.delete(:any_widget) if params[:restore_default]
      @profile.widget_config = widget_config.inspect
      @profile.save!
    end
    @widget = (@profile.widget_config && eval(@profile.widget_config)[:any_widget]) ? eval(@profile.widget_config)[:any_widget] : DefaultWidget.get.content
    if params[:mode] == "settings"
      render :template => 'widgets/my_widget_settings', :layout => false
    else
      render :template => 'widgets/my_widget', :layout => false
    end
  end

  def update_widget_sequence
    widget_config = @profile.widget_config ? eval(@profile.widget_config) : {}
    widget_config[:seq_1] = params[:group1] ? params[:group1] : []
    widget_config[:seq_2] = params[:group2] ? params[:group2] : []
    @profile.widget_config = widget_config.inspect
    @profile.save!
    render :nothing => true
  end

  def toggle_widget
    widget_config = @profile.widget_config ? eval(@profile.widget_config) : {}
    collapsed_widgets = widget_config[:collapsed] ? widget_config[:collapsed] : []
    collapsed_widgets.include?(params[:widget_id]) ? collapsed_widgets.delete(params[:widget_id]) : collapsed_widgets << params[:widget_id]
    widget_config[:collapsed] = collapsed_widgets
    @profile.widget_config = widget_config.inspect
    @profile.save!
    render :nothing => true
  end

  def update
    if is_editable?(@profile)
      @profile.update_attributes( params[:profile] )
      respond_to do |format|
        format.json { render :text => @profile.to_json }
      end
    end
  end

  def refresh_hot_topics_widget
    @random_terms = TopTerm.random_terms('questions', 24)
    respond_to do |format|
      format.html { redirect_to '/' }
      format.js { render :partial => 'widgets/hot_topics', :layout => false }
    end
  end

  def refresh_explore_profiles_widget
    @random_profiles = Profile.random_visible_profiles(15)
    respond_to do |format|
      format.html { redirect_to '/' }
      format.js { render :partial => 'widgets/explore_profiles', :layout => false }
    end
  end

  def hub
    @all_widgets = all_widgets
    
    @square_button_1 = hub_ad_units['square_button_1']
    @square_button_2 = hub_ad_units['square_button_2']
    @notes = @profile.notes.find(:all, :limit => 3)
    @random_terms = TopTerm.random_terms('questions', 24)
    @random_profiles = Profile.random_visible_profiles(15)
    @questions_with_new_answers = @profile.questions_with_new_answers
    @system_announcement = SystemAnnouncement.get_if_active
    @random_marketing_message = MarketingMessage.random_active_message
    @referred_questions = @profile.questions_referred_to_me.referral_owner(@profile).summary
    @matched_questions = @profile.matched_questions
    @watched_questions = @profile.watched_questions.summary
    widget_config = @profile.widget_config ? eval(@profile.widget_config) : {}
    @group1 = widget_config[:seq_1] ? widget_config[:seq_1] : group_1_widgets #(1..(@all_widgets.size/2.0).ceil).collect{|x| x.to_s}
    @group2 = widget_config[:seq_2] ? widget_config[:seq_2] : group_2_widgets #(((@all_widgets.size/2.0).ceil + 1)..@all_widgets.size).collect{|x| x.to_s}
    @collapsed_widgets = widget_config[:collapsed] ? widget_config[:collapsed] : []
    @widgets = @all_widgets
    @active_users = Profile.active_users_count
  end

  def questions_answered
    @question_summaries = Question.questions_answered(@profile.id, question_filters)
    render :layout => 'q_and_a_sub_menu'
  end

  def questions_with_best_answers
    @questions_title = ((logged_in? && @profile == current_profile) ? "I " : "#{@profile.screen_name} ") + "Answered Best"
    @question_summaries = Question.questions_answered_with_best_answers(@profile.id, question_filters)
    render :template => 'questions/index'
  end

  def questions_asked
    @question_summaries = @profile.questions.find(:all, question_filters({:referral_owner => @profile}))
    render :layout => 'q_and_a_sub_menu'
  end

  def groups
    @invitations = @profile.received_invitations
    @groups = @profile.groups
    render :layout => '_my_stuff'
  end

  def matched_questions
    respond_to do |format|
      format.html {
        if @profile == current_profile
          @questions = @profile.matched_questions(:page => {:size => 5, :current => params[:questions_page]})
          # SSJ FIX -- this should be done in query not here 
          @questions = @questions.select { |q| q.is_open? }
          @referred_questions = @profile.questions_referred_to_me.referral_owner(@profile).summary
          # SSJ FIX -- this should be done in query not here
          @referred_questions = @referred_questions.select { |q| q.is_open? }
          render :layout => 'q_and_a_sub_menu'
        else
          redirect_to profile_path(@profile)
        end
      }
    end
  end

  def more_matched_questions
    @questions = SemanticMatcher.default.find_questions_relevant_to_profile(Question, @profile, :summary => true, :limit => 1, :page => { :size => 5, :current => params[:questions_page] } )
    if @questions.size < 1
      @questions = SemanticMatcher.default.find_more_questions_to_answer(Question, @profile, :summary => true, :limit => 1, :page => { :size => 5, :current => params[:questions_page] } )
    end

    respond_to do |format|
      format.js {
        if @questions.size > 0
          render :partial => "questions/questions", :layout => false, :locals => { :questions_for => @profile, :domain => 'more_matched_questions', :questions => @questions, :show => { :remove => true } }
        else
          render :partial => "profiles/no_more_matched_questions", :layout => false
        end
      }
    end
  end

  def show
    @selected_photo = @profile.primary_photo || @profile.profile_photos[0]
    @profile.increment_profile_views! unless @profile==current_profile
    @profile_stats = @profile.stats

    current_profile.update_attributes(:karma_abducted => true) unless current_profile.karma_abducted? || @profile==current_profile

    render :action => 'profile', :layout => '_my_stuff'
  end
  alias :my :show #!I my sets @profile to current profile  for /profile route

  def external
    respond_to do |format|
      format.html { redirect_to profile_path(@profile) }
      format.xml { render :action => 'show.rxml', :layout => false }
    end
  end

  def external_widget
    @latest_group_post = GroupPost.first(:joins => "join group_memberships gm on gm.group_id = group_posts.group_id and gm.profile_id = #{@profile.id}", :order => "group_posts.created_at desc")
    @latest_answered_on_watch_list = Question.first(:joins => "join answers a on a.question_id = questions.id join bookmarks b on b.question_id = questions.id and b.profile_id = #{@profile.id}", :order => "a.created_at desc")
    @matched_questions = (@profile.questions_referred_to_me(:summary => false).size + @profile.matched_questions(:summary => false).size)
    @new_group_posts = GroupPost.count(:joins => "join group_memberships gm on gm.group_id = group_posts.group_id and gm.profile_id = 1", :order => "group_posts.created_at desc", :conditions => ["group_posts.created_at > ?", @profile.last_accessed])
    @new_blog_posts = WatchEvent.count(:joins => "join watches using (watchable_type, watchable_id)", :conditions => ["action_item_type = 'BlogPost' and watcher_id= ? and watch_events.created_at > ?", @profile.id, @profile.last_accessed ])
    
    respond_to do |format|
      format.html {
        @random_profiles = Profile.random_visible_profiles(4)
        render :template => 'widgets/external_widget', :layout => false
        }
      format.xml { render :action => 'external_widget.rxml', :layout => false }
    end
  end

  def notes
    respond_to do |format|
      format.xml{
        opts = {}
        opts[:limit] = params[:limit].to_i if params[:limit]
        @notes = @profile.notes.allow_profile_or_admin_to_see_all_for_receiver(current_profile, @profile).find(:all,opts)
        render :template => 'notes/show', :layout => false
      }
    end
  end

  def watched_questions
    @questions = @profile.watched_questions.find(:all, :summary => true, :page => default_paging)
    respond_to do |format|
      format.html {render :layout => 'q_and_a_sub_menu'}
    end
  end
  
  def awards_popup
    @profile_awards = @profile.profile_awards
    respond_to do |format|
      format.js { render(:partial => 'profiles/awards_popup', :layout => '/layouts/popup') }
    end
  end

  def karma_popup
    respond_to do |format|
      format.html { render(:partial => 'profiles/karma_popup', :layout => '/layouts/popup') }
    end
  end
  
  def completion_popup
    respond_to do |format|
      format.html { render(:partial => 'profiles/completion_popup', :layout => '/layouts/popup')}
    end
  end

  private

  #!R the logic in here is disconnected from the actual action, need a better way to handle -jc
  def check_profile_active_status
    unless @profile and (@profile==current_profile or @profile.visible?)
      respond_to do |format|
        format.html{
          add_to_notices "The profile you are trying to view is no longer available"
          redirect_to '/our_story' #TODO => redirect to where?
        }
        format.xml{
          @profile= Profile.new
          @profile.user = User.new
          render :action => 'show.rxml', :layout => false
        }
        format.js{
          render :nothing => true
        }
      end
    end
  end

  def set_user_and_profile
    action = params[:action].to_sym
    if action == :external || action == :external_widget
      if(params[:id])
        @profile = Profile.find(:first, :conditions => [ 'users.sso_id=?', params[:id]])
      elsif (params[:login])
        @profile = Profile.find(:first, :conditions => [ 'users.login=?', params[:login]])
      end
    elsif [:my, :hub, :my_widget, :toggle_widget, :update_widget_sequence].include?(action)
      @profile = current_profile
    else
      @profile = Profile.find(params[:id])
    end
  end

end