module FilterSortHelper

  @@filter_options = {
    'Question' => [['All','all'], ['Open','open'], ['Closed','closed'], ['Unanswered','unanswered']],
    'Group' => [['All','all'], ['Public','public'], ['Invite Only','invite_only'], ['Private','private'], ['Sponsored', 'sponsored']],
    'Watch' => [['All','all'], ['Questions','questions'], ['Question Referrals','referrals'], ['Blog Posts','blog_posts']],
    'Watch_profile' => [['All','all'], ['Questions','questions'], ['Blog Posts','blog_posts']],
    'Watch_group' => [['All','all'], ['Question Referrals','referrals'], ['Blog Posts','blog_posts']],
    'Travel' => [["All",'all'], ["Arrivals","arrivals"],["Departures","departures"], ],
    'Status' => [["Matching Text",'text'], ["Matching People","author"] ]
  }

  @@sort_options = {
    'Question' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Most Answers","most_answers"],["Least Answers","least_answers"],["Relevance","relevance"]],
    'Answer' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Most Helpful","most_helpful"]],
    'Group' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Most Members","most_members"], ["Most Activity", "most_activity"],["Relevance","relevance"]],
    'Profile' => [["Last Name","last_first"],["First Name","first_last"]],
    'Post' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Best Rating", "best_rating"], ["Most Comments", "most_comments"]],
    'BlogPost' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Highest Rated", "highest_rating"],["Most Comments", "most_comments"]],
    'GalleryPhoto' => [["Newest to Oldest", "newest_to_oldest"],["Oldest to Newest", "oldest_to_newest"],["Highest Rated", "highest_rating"],["Most Comments", "most_comments"]],
    #'Travel' => [["Upcoming Iteneraries","testing"],["Past Iteneraries","testing"]]
  }

  # @@category_options = {
  #   'Question' => ['All'] + Question.categories.sort
  # }
  def category_options
    { 'Question' => ['All'] + Question.categories.sort }
  end

  def filter_sort_controls(type, options={})
    category_filter_sort_controls(type,[:sort, :filter], options)
  end

  def sort_control(type, options={})
    category_filter_sort_controls(type,[:sort], options)
  end

  def filter_control(type, options={})
    category_filter_sort_controls(type,[:filter], options)
  end

  def category_filter_sort_controls(item_class_name, args=[:sort, :filter, :categorize], options={})
    options[:category_options] = category_options[item_class_name] if args.include?(:categorize)
    options[:filter_options] = @@filter_options[item_class_name] if args.include?(:filter)
    options[:sort_options] = @@sort_options[item_class_name] if args.include?(:sort)
    filter_sort_form(options)
  end

  def filter_links_for(options, scope)
    options[:filter_options].compact.collect{|text, value|
      scope == value ? "<dd class=\"selected\"><span>#{text}</span></dd>" : "<dd>" + link_to(text,"?query=#{params[:query]}&filter_category=#{params[:filter_category]}&filter_scope=#{value}&filter_order=#{params[:filter_order]}") + "</dd>"
    }.join("")
  end
  
  def filter_select_for(options)
    select_tag('filter_scope', options_for_select(options[:filter_options], params[:filter_scope]))
  end

  def sort_select_for(options)
    select_tag('filter_order', options_for_select(options[:sort_options], params[:filter_order]))
  end

  def category_select_for(options)
    select_tag('filter_category', options_for_select(options[:category_options], params[:filter_category]))
  end

  def filter_sort_form(options)
    render :partial => 'shared/filter_form', :locals => {:options => options}
  end

end