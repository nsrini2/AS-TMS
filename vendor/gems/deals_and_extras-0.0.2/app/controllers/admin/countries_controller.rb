class Admin::CountriesController < AdminController

  def index
    @page_title = "Countries"
    
    per_page = 25
    
    @countries = Country.paginate(:page => params[:page], :per_page => per_page)
    
  end

end
