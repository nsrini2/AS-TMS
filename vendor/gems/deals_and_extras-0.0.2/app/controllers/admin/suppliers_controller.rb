class Admin::SuppliersController < AdminController

  def index
    @page_title = "Suppliers"
    per_page = 25
    @suppliers = Supplier.paginate(:page => params[:page], :per_page => per_page)
  end

  def new
    @supplier = Supplier.new
  end

  def edit
    @supplier = Supplier.find(params[:id])
    render :new
  end

  def create
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = "Supplier saved."
      redirect_to admin_suppliers_path
    else
      flash[:error] = "Supplier NOT saved."
      render :new
    end
  end

  def update
    @supplier = Supplier.find(params[:id])
    @supplier.update_attributes(params[:supplier])
    if @supplier.save
      flash[:notice] = "Supplier updated."
      redirect_to admin_suppliers_path
    else
      flash[:error] = "Supplier NOT updated."
      render :new
    end
  end

  def show
    redirect_to edit_admin_supplier_path(params[:id])
  end

end
