require 'will_paginate/array'

class SearchController < ApplicationController
  
  # interim security fix for xss injection on a param that is re-displayed to the user
  before_filter :sanitize_query
  def sanitize_query
    params[:query] ||= params[:q]
    @query = params[:query] = RailsSanitize.white_list_sanitizer.sanitize(params[:query]) if params.member?(:query)
  end
  
  def index          
    @results = []

    params[:scope] = nil if params[:scope] == "all"
    scope = params[:scope]
    
    unless scope && scope != "question"
      question_options = question_filters
      question_options.delete(:page)
      
      @questions = Question.find_by_keywords(@query, question_options)
      @results << @questions.to_a
    end 
    
    unless scope && scope != "profile"    
      profile_options = profile_filters
      profile_options.delete(:page)
      
      @profiles = Profile.all_visible_profiles_by_full_name(@query, profile_options)
      @profiles = @profiles.to_a
    
      @smart_profiles = Profile.find_by_smarts(@query, profile_options)
      @results << @smart_profiles.to_a
    end
    
    unless scope && scope != "group"
      group_options = group_filters
      group_options.delete(:page)
      
      @groups = Group.find_by_keywords(@query, group_options)
      @results << @groups.to_a
    end
    
    unless scope && scope != "blog"
      blog_options = blog_filters
      blog_options.delete(:page)
  
      # Only show public groups
      ModelUtil.add_joins!(blog_options, "left join blogs bgs on bgs.id = blog_posts.blog_id")
      ModelUtil.add_joins!(blog_options,"left join groups pg on pg.id = bgs.owner_id and bgs.owner_type = 'Group' and pg.group_type = 2")
      ModelUtil.add_conditions!(blog_options,"pg.id is null")
      ModelUtil.add_conditions!(blog_options,"bgs.owner_type <> 'Company'")
    
      @blogs = BlogPost.find_by_keywords(@query, blog_options)
      @results << @blogs.to_a
    end
    
    unless scope && scope != "status" 
      status_options = status_filters
      status_options.delete(:page)
      
      @statuses = Status.find_by_keywords(@query, status_options)
      @results << @statuses.to_a
    end
    
    unless scope && scope != "chats" 
      topic_options = topic_filters
      topic_options.delete(:page)
      
      @topics = Topic.find_by_index(@query, topic_options)
      @results << @topics.to_a
    end
    
    # Sort based on rank
    @results = @results.flatten.compact.sort{ |a,b| b["rank"].to_f <=> a["rank"].to_f }
    
    # First/Last Name matches always go to the top
    @results = [@profiles, @results].flatten.compact unless @profiles.nil?
    
    # Setup paging manually
    # page_size = 10
    # current_page = params[:search_page] ? params[:search_page].to_i : 1
    #   
    # paging_results = PagingEnumerator.new(page_size, @results.size, false, current_page, 1)     
    # paging_results.results = @results[(current_page-1)*page_size..(current_page*page_size)-1]
    #   
    # @results = paging_results
    @results = @results.paginate(:per_page => 10, :page => params[:page])
    
    
    @filters = {  "all" => "All",
                  "blog" => "Blog Posts",
                  "group" => "Groups",
                  "profile" => "People",
                  "question" => "Questions",
                  "status" => "Updates",
                  "chats" => "Chats"
                }
  end
  
end