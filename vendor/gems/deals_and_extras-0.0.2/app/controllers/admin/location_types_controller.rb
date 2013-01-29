class Admin::LocationTypesController < AdminController

  def index
    @page_title = "Location Types"
    
    per_page = 25
    
    @location_types = LocationType.paginate(:page => params[:page], :per_page => per_page)
    
  end

end
