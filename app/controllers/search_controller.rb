class SearchController < ApplicationController
  
  # TODO: Sanitize query
  def index
    @query = params[:q]
    
    @results = Question.search @query
  end
  
end