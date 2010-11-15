require_cubeless_engine_file :controller, :activity_stream_events_controller

class ActivityStreamEventsController
  
  def index
    @events = ActivityStreamEvent.find_summary(:all, :page => default_paging(7))
  end
  
end