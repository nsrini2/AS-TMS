class ExplorationsController < ApplicationController
  deny_access_for :all => :sponsor_member
  
  before_filter :verify_video_enabled, :only => [:videos]
  
  
  # interim security fix for xss injection on a param that is re-displayed to the user
  before_filter :sanitize_query
  def sanitize_query
    @query = params[:query] = RailsSanitize.white_list_sanitizer.sanitize(params[:query]) if params.member?(:query)
  end
  
  before_filter :verify_travel_enabled, :only => [:travels]

  def smarts
    options = profile_filters
    @profile_results = Profile.find_by_smarts(@query, options) unless @query.blank?
    render_profile_results do
      render_new_exploration_page :selected_tab => :smarts_tab, :tag_cloud_for => (:profiles if @query.blank?),
        :search_text => 'Search profiles for these terms'
    end
  end

  def questions
    @wide_skyscraper = exploration_ad_units['questions']['wide_skyscraper']
    options = question_filters
    options.delete(:page)
    options.delete(:summary)
    options.merge!(:page => params[:page])
    @question_summaries = @query.blank? ? Question.paginate(options) : Question.find_by_keywords(@query, options)
    render_question_results
  end
  alias :new :questions

  def groups
    @groups = filtered_groups.paginate(:page => params[:page], :per_page => 7)
    @wide_skyscraper = exploration_ad_units['groups']['wide_skyscraper']
    render_group_results
  end

  def people
    options = profile_filters
    @profile_results = Profile.all_visible_profiles_by_full_name(@query, options) unless @query.blank?
    if @query.blank? || @profile_results.size.zero?
      if params[:filter_order] == "last_accessed"
        options[:order] = "last_accessed desc"
        options[:page] = default_paging(60)
        options[:conditions] = "last_accessed>timestampadd(minute,-30,now())"
        @profiles = Profile.all(options)
      else
        @profiles = Profile.random_visible_profiles(60)
      end
    end
    render_profile_results
  end
  
  def blogs
    @wide_skyscraper = exploration_ad_units['blogs']['wide_skyscraper']
    # options = blog_filters
    # 
    # ModelUtil.add_joins!(options,"left join groups pg on pg.id = blogs.owner_id and blogs.owner_type = 'Group' and pg.group_type = 2")
    # ModelUtil.add_conditions!(options,"pg.id is null")
    # ModelUtil.add_conditions!(options,"blogs.owner_type <> 'Company'")
    # 
    # @blogs = @query.blank? ? BlogPost.find(:all, options) : BlogPost.find_by_keywords(@query, options)
    Rails.logger.info "IN "
    @blogs = filtered_blogs.joins('INNER JOIN blogs ON blog_posts.blog_id = blogs.id').where("blogs.owner_type <> 'Company'").paginate(:page => params[:page], :per_page => 7)
    render_blog_results
  end
    
  def videos
    # @wide_skyscraper = exploration_ad_units['questions']['wide_skyscraper']
    
    options = video_filters
    @videos = @query.blank? ? Video.find(:all, options) : Video.find_by_keywords(@query, options)
    render_video_results
  end
 
  def travels    
    options = travel_filters
    @travels = @query.blank? ? GetthereBooking.find(:all, options) : GetthereBooking.find_by_keywords(@query, options)
    render_travel_results
  end

  def statuses
    options = status_filters
    
    @statuses = @query.blank? ? Status.find(:all, options) : Status.find_by_keywords(@query, options)
    render_status_results
  end

  def question_referrers
    options = profile_filters
    @profile_results =  Question.find(params[:question_id]).profiles_who_referred_to(current_profile.id, options)
    render_profile_results(:people)
  end

  def profiles_referred_to_question
    options = profile_filters
    @profile_results = Question.find(params[:question_id]).referred_to_profiles_by(params[:referer_id], options)
    render_profile_results(:people)
  end

  def groups_referred_to_question
    @groups = Question.find(params[:question_id]).referred_to_groups_by(params[:referer_id]).paginate(:page => params[:page], :per_page => 7)
    render_group_results(:groups)
  end

  private

  def top_terms(type)
    TopTerm.terms_for_tag_cloud(type)
  end

  def render_new_exploration_page(options={})
    @cloud_terms = top_terms(options[:tag_cloud_for].to_sym) if options[:tag_cloud_for]
    @selected = options[:selected_tab].to_s
    @explore_text = options[:search_text].to_s
    @form_action = options[:form_action].to_s if options[:form_action]
    render :action => 'new', :layout => 'exploration'
  end

  def render_profile_results(action=nil, &block)
    add_to_notices 'Sorry! No people match.' if @profile_results && @profile_results.size.zero?
    if @profile_results && @profile_results.size==1
      redirect_to profile_path(@profile_results.find{true})
    elsif block_given?
      yield
    else
      render_new_exploration_page :selected_tab => :people_tab, :search_text => 'Search by first name, last name or both', :form_action => action
    end
  end

  def render_group_results(action=nil)
    add_to_notices 'Sorry! No groups match.' if @groups && @groups.size.zero?
    render_new_exploration_page :selected_tab => :groups_tab, :search_text => 'Search groups for these terms', :form_action => action
  end

  def render_blog_results(action=nil)
    add_to_notices 'Sorry! No blogs match your terms.' if @blogs && @blogs.size.zero?
    render_new_exploration_page :selected_tab => :blogs_tab, :search_text => 'Search blogs for these terms or by author name', :form_action => action
  end

  def render_video_results(action=nil)
    add_to_notices 'Sorry! No videos match your terms.' if @videos && @videos.size.zero?
    render_new_exploration_page :selected_tab => :videos_tab, :search_text => 'Search video titles and description for these terms', :form_action => action
  end

  def render_question_results
    add_to_notices 'Sorry! No questions match. Ask your own question by clicking the ask link above.' if @question_summaries && @question_summaries.size.zero?
    render_new_exploration_page :selected_tab => :question_tab, :search_text => 'Search questions for these terms'
  end

  def render_travel_results
    add_to_notices 'Sorry! No matching intineraries.'  if @travels && @travels.size.zero?
    render_new_exploration_page :selected_tab => :travels_tab, :search_text => 'Search by location' 
  end

  def render_status_results
    add_to_notices 'Sorry! No matching statuses.'  if @statuses && @statuses.size.zero?
    render_new_exploration_page :selected_tab => :statuses_tab, :search_text => 'Search' 
  end
end
