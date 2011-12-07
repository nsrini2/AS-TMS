class Admin::SupplierUsersController < AdminController

  def index
    @supplier_users = SupplierUser.all
  end

  def edit
    @supplier_user = SupplierUser.find(params[:id])
  end

  def new
    @supplier_user = SupplierUser.new
  end

  def create
    @supplier_user = SupplierUser.create(params[:supplier_user])
    if(@supplier_user.save)
      redirect_to admin_supplier_users_path
    else
      render admin_supplier_user_new
    end
  end

  def destroy
    @supplier_user = SupplierUser.find(params[:id])
    if(@supplier_user.delete)
      redirect_to admin_supplier_users_path
    else
      render edit_admin_supplier_path
    end
  end

  def update
    @supplier_user = SupplierUser.find(params[:id])
    @supplier_user.update_attributes(params[:supplier_user])
    if(@supplier_user.save)
      redirect_to admin_supplier_users_path
    else
      render edit_admin_supplier_path
    end
  end

end
