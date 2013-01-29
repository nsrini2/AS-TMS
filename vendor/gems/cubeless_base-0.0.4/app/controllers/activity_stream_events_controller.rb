class ActivityStreamEventsController < ApplicationController
  
  def index
    @events = ActivityStreamEvent.find_summary(:all, :page => default_paging(20))
  end
  
end