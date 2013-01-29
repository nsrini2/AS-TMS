class Admin::StateProvincesController < AdminController

  def index
    @page_title = "States / Provinces"
    
    per_page = 25
    
    @states_provinces = StateProvince.paginate(:page => params[:page], :per_page => per_page)
    
  end

end
