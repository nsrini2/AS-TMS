require 'will_paginate/array'

class SearchController < ApplicationController
  
  # interim security fix for xss injection on a param that is re-displayed to the user
  before_filter :sanitize_query
  def sanitize_query
    params[:query] ||= params[:q]
    @query = params[:query] = RailsSanitize.white_list_sanitizer.sanitize(params[:query]) if params.member?(:query)
  end
  
  def index
    @results = SiteSearch.search(params)     
    @filters = {  "all" => "All",
                  "blog_posts" => "Blog Posts",
                  "groups" => "Groups",
                  "profiles" => "People",
                  "questions" => "Questions",
                  "chats" => "Chats"
                }
  end
  
end