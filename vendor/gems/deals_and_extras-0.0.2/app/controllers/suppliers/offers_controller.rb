class Suppliers::OffersController < SuppliersController

  # before_filter :authenticate_supplier_user!
  before_filter :require_auth
  allow_access_for [:all] => [:cubeless_admin, :content_admin]

  def index
    
  end

  def create

    # supplier = Supplier.find current_supplier_user.supplier_id
    supplier = if params[:supplier_id]
                 Supplier.find params[:supplier_id]
               else
                 Supplier.find current_supplier_user.supplier_id
               end

    state_province = StateProvince.find(params[:supplier][:state_province_id])

    address_1      = params[:supplier]['address_1']
    address_2      = params[:supplier]['address_2']
    address_3      = params[:supplier]['address_3']
    city           = params[:supplier]['city']
    postal_code    = params[:supplier]['postal_code']
    full_address = "#{address_1} #{address_2} #{address_3} #{city}, #{state_province.abbreviation} #{postal_code}"


      location = Location.find_or_create_by_description(full_address)
    begin
      location.update_latlon
    rescue
      nil
    end    
      location.save

    
    offer = Offer.create(params[:offer])
    
    offer.locations.push location
    offer.suppliers.push supplier

    redirect_to new_suppliers_offer_path
  end

end
