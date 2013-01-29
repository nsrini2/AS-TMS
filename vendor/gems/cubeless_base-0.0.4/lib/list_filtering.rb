module ListFiltering

  @@question_sort_options_list = {'newest_to_oldest' => 'questions.created_at desc', 'oldest_to_newest' => 'questions.created_at', 'most_answers' => 'questions.answers_count desc', 'least_answers' => 'questions.answers_count', 'relevance' => nil}
  @@question_scope_options = {'closed' => 'questions.open_until <= current_date', 'open' => 'questions.open_until > current_date', 'unanswered' => '!exists (select 1 from answers where question_id=questions.id limit 1)'}
  @@question_categories = Set.new(Question.categories)
  def question_filters(find_options={})
    scope = params['filter_scope'] || params.store('filter_scope','all')
    category = params['filter_category'] || params.store('filter_category', 'All')
    ModelUtil.add_conditions!(find_options,@@question_scope_options[scope]) if @@question_scope_options.member?(scope)
    ModelUtil.add_conditions!(find_options,['questions.category = ?', category]) if @@question_categories.member?(category)
    find_options[:order] ||= @@question_sort_options_list[params['filter_order'] || params.store('filter_order',params['query'].blank? ? 'newest_to_oldest' : 'relevance')]
    # SSJ now using will_paginate so delete this
    # find_options[:page] ||= default_paging 
    find_options.delete(:page)
    find_options[:summary] ||= true
    find_options
  end

  @@answer_sort_options_list = {'newest_to_oldest' => 'answers.created_at desc', 'oldest_to_newest' => 'answers.created_at', 'most_helpful' => 'net_helpful desc, num_positive_votes desc'}
  def answer_filters(find_options={})
    find_options[:order] ||= @@answer_sort_options_list[params['filter_order'] || params.store('filter_order','newest_to_oldest')]
    # SSJ now using will_paginate so delete this
    # find_options[:page] ||= default_paging
    # find_options.delete(:page)
    find_options[:summary] ||= true
    find_options
  end

  @@group_sort_options_list = {'newest_to_oldest' => 'groups.created_at desc', 'oldest_to_newest' => 'groups.created_at', 'most_members' => 'groups.group_memberships_count desc', 'most_activity' => 'groups.activity_status desc', 'relevance' => nil}
  @@group_scope_options = {'public' => 'groups.group_type = 0', 'invite_only' => 'groups.group_type = 1', 'private' => 'groups.group_type = 2', 'sponsored' => 'exists (select 1 from profiles where groups.owner_id=profiles.id and profiles.roles like "%6%")' }
  def group_filters(find_options={})
    Rails.logger.warn "DEPRECATION WARNING: group_filters is depricated, use filtered_groups instead. Nov. 11, 2011"
    scope = params['filter_scope'] || params.store('filter_scope', 'all')
    ModelUtil.add_conditions!(find_options,@@group_scope_options[scope]) if @@group_scope_options.member?(scope)
    find_options[:order] ||= @@group_sort_options_list[params['filter_order'] || params.store('filter_order',params['query'].blank? ? 'newest_to_oldest' : 'relevance')]
    find_options[:page] ||= default_paging
    find_options
  end
  def filtered_groups(find_options={})
    group_types = {'all' => 'groups.group_type >= 0', 'public' => 'groups.group_type = 0', 'invite_only' => 'groups.group_type = 1', 'private' => 'groups.group_type = 2', 'sponsored' => 'exists (select 1 from profiles where groups.owner_id=profiles.id and profiles.roles like "%6%")' }
    order_hash = {'newest_to_oldest' => 'groups.created_at desc', 'oldest_to_newest' => 'groups.created_at', 'most_members' => 'groups.group_memberships_count desc', 'most_activity' => 'groups.activity_status desc', 'relevance' => nil}
    Rails.logger.info "using new filterd_groups"
    filter_order = params[:filter_order] || "newest_to_oldest"
    filter_scope = params[:filter_scope] || 'all'
    
    Group.where(group_types[filter_scope]).order(order_hash[filter_order])
  end

  @@profile_sort_options_list = {"last_first" => "last_name, first_name", "first_last" => "first_name, last_name"}
  def profile_filters(find_options={})
    find_options[:order] ||= @@profile_sort_options_list[params['filter_order'] || params.store('filter_order','last_name, first_name')]
    find_options[:page] ||= default_paging
    find_options[:status] ||= :visible
    find_options
  end

  @@watch_scope_options = { 'questions' => 'watch_events.action_item_type = "Question"', 'referrals' => 'watch_events.action_item_type = "QuestionReferral"', 'blog_posts' => 'watch_events.action_item_type = "BlogPost"'}
  def watch_filters(find_options={})
    scope = params['filter_scope'] || params.store('filter_scope', 'all')
    ModelUtil.add_conditions!(find_options,@@watch_scope_options[scope]) if @@watch_scope_options.member?(scope)
    find_options[:page] ||= default_paging
    find_options
  end
  
  @@blog_sort_options_list = { 'newest_to_oldest' => 'blog_posts.created_at desc', 'oldest_to_newest' => 'blog_posts.created_at', 'highest_rating' => 'blog_posts.rating_avg desc, blog_posts.created_at desc', 'most_comments' => 'blog_posts.comments_count desc, blog_posts.created_at desc' }
  def blog_filters(find_options={})
    Rails.logger.warn "DEPRECATION WARNING: blog_filters is depricated, use filtered_blogs instead. Nov. 11, 2011"
    find_options[:order] ||= @@blog_sort_options_list[params['filter_order'] || params.store('filter_order','newest_to_oldest')]
    find_options[:page] ||= default_paging(5)
    find_options
  end
  def filtered_blogs(find_options={})
    order_hash = { 'newest_to_oldest' => 'blog_posts.created_at desc', 'oldest_to_newest' => 'blog_posts.created_at', 'highest_rating' => 'blog_posts.rating_avg desc, blog_posts.created_at desc', 'most_comments' => 'blog_posts.comments_count desc, blog_posts.created_at desc' }
    Rails.logger.info "using new filterd_blogs"
    filter_order = params[:filter_order] || "newest_to_oldest"
    BlogPost.order(order_hash[filter_order])
  end
  # MM2: For arrivals the ? is set within the mysql_semantic_matcher
  @@travel_sort_options_list = { 'by_date' => 'getthere_bookings.start_time ASC' }
  @@travel_scope_options = {'all' => nil, 
                            'arrivals' => 'getthere_bookings.locations IS NOT NULL', #'getthere_bookings.locations LIKE ? OR getthere_bookings.destination_airport_codes LIKE ?', 
                            'departures' => 'getthere_bookings.start_location IS NOT NULL'}#'getthere_bookings.start_location LIKE ? OR getthere_bookings.start_airport_code LIKE ?'}
  def travel_filters(find_options={})
    scope = params['filter_scope'] || params.store('filter_scope', 'all')
    
    # MM2: Only show travels that are public
    find_options[:conditions] = ModelUtil.add_conditions!(find_options, ['getthere_bookings.public  = ?', true])
    
    # MM2: Only show travels that have not already happened
    find_options[:conditions] = ModelUtil.add_conditions!(find_options, ['getthere_bookings.end_time > ?', Time.now])
    
    ModelUtil.add_conditions!(find_options, [@@travel_scope_options[scope]]) if @@travel_scope_options.member?(scope) && !@@travel_scope_options[scope].nil?
    
    find_options[:order] ||= @@travel_sort_options_list[params['filter_order'] || params.store('filter_order','by_date')]
    find_options[:page] ||= default_paging(10)
    find_options
  end
  
  # MM2: Actual scoping is handling in the mysql semantic matcher
  @@status_scope_options = { 'all' => nil,
                             'text' => 'text',
                             'author' => 'author' }
  def status_filters(find_options={})
    scope = params['filter_scope'] || (@query.blank? ? params.store('filter_scope', 'all') : params.store('filter_scope', 'text'))
    
    ModelUtil.add_conditions!(find_options, [@@status_scope_options[scope]]) if @@status_scope_options.member?(scope) && !@@status_scope_options[scope].nil?

    find_options[:order] ||= "statuses.created_at DESC" 
    find_options[:page] ||= default_paging(10)
    find_options
  end
  
  # SSJ: borrowed from status scope options...
  @@topic_scope_options = { 'all' => nil}
  def topic_filters(find_options={})
    # SSJ : not used today but may be needed in future...
    # scope = params['filter_scope'] || (@query.blank? ? params.store('filter_scope', 'all') : params.store('filter_scope', 'text'))
    # ModelUtil.add_conditions!(find_options, [@@topic_scope_options[scope]]) if @@topic_scope_options.member?(scope) && !@@topic_scope_options[scope].nil?
    
    # SSJ: you must create a rank column to use this param...
    find_options[:order] ||= "rank DESC"
    find_options[:page] ||= default_paging(10)
    find_options
  end

  @@gallery_photo_sort_options_list = { 'oldest_to_newest' => 'gallery_photos.created_at', 'newest_to_oldest' => 'gallery_photos.created_at desc', 'highest_rating' => 'gallery_photos.rating_avg desc, gallery_photos.created_at desc', 'most_comments' => 'gallery_photos.comments_count desc, gallery_photos.created_at desc' }
  def gallery_photo_filters(find_options={})
    find_options[:order] ||= @@gallery_photo_sort_options_list[params['filter_order'] || params.store('filter_order','newest_to_oldest')]
    find_options[:page] ||= default_paging(15)
    find_options
  end
  
  @@video_sort_options_list = { 'newest_to_oldest' => 'videos.created_at DESC'}
  def video_filters(find_options={})
    find_options[:order] ||= @@video_sort_options_list[params['filter_order'] || params.store('filter_order','newest_to_oldest')]
    find_options[:page] ||= default_paging(2)
    
    # Only show encoded videos
    ModelUtil.add_conditions!(find_options, ["encoded = ?", true])
    
    find_options
  end
end