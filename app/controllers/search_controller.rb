class SearchController < ApplicationController
  
  # TODO: Sanitize query
  def index
    @query = params[:q]
  end
  
end