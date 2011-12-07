class Admin::SupplierTypesController < AdminController

  layout 'admin'

  def index
    @page_title = "Supplier Types"
    
    per_page = 25
    
    @supplier_types = SupplierType.paginate(:page => params[:page], :per_page => per_page)
    
  end

end
