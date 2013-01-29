class Admin::LocationsController < AdminController

  def index
    @page_title = "Locations"
    
    per_page = 25
    
    @locations = Location.paginate(:page => params[:page], :per_page => per_page)
  end
  
  def show
    
    @location = Location.find(params[:id])
    
  end
  
  def edit
    @location = Location.find(params[:id])
    render 'new'
  end

  def update
    @location = Location.find(params[:id])
    @location.update_attributes(params[:location])
    @location.save
    render :new
  end
  
  def update_latlon
    location = Location.find(params[:id])
    result = location.update_latlon
    respond_to do |f|
      f.js { render :json =>  result }
      f.html { redirect_to :back }
    end
  end

end
