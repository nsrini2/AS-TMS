class Admin::OffersController < AdminController

  before_filter :init

  def init
    @states = StateProvince.OPTIONIZE
    @offer_types = OfferType.OPTIONIZE
  end

  def index
    @page_title = "Offers"
    @all_offers = Offer.approved.filter(params)
    @supplier_id =  params[:supplier] || nil
    @query = params['query']
  end

  def new
    @page_title = "New Offer"
    @offer = Offer.new
  end

  def create
    if params['file']
      o = Offer.new_from_xml(params['file'].read)
    end
    redirect_to :admin_offers
  end

  def show
    redirect_to edit_admin_offer_path(params[:id])
  end

  def update
    @offer = Offer.find(params[:id])
    @offer.update_attributes(params[:offer])
    
    if @offer.save
      flash[:notice] = "Offer Saved."
      # redirect_to :admin_offers
      
      # Assume dashboard
      # redirect_to '/deals_and_extras/admin/index'
      
      # Special for Marcelo
      next_offer = Offer.pending.not_deleted.first
      redirect_to edit_admin_offer_path(next_offer)
      
    else
      flash[:error] = "Offer NOT Saved!"
      render :new
    end
  end

  def edit
    @page_title = "Edit Offer #" + params[:id].to_s
    @offer = Offer.find(params[:id])
    @states = StateProvince.OPTIONIZE
    render :new
  end

  def update_latlong
    offer = Offer.find(params[:id])
    output = "error"
    if offer.update_latlong
      output = "#{offer.lat} / #{offer.long}"
    end
    render :text => output
  end
  
  def mass_update
    count = 0

    params['offer'].each_pair do |offer_id, updates|
      approve = (updates['approve'].to_s == 1.to_s)
      delete = (updates['delete'].to_s == 1.to_s)
      if approve || delete
        o = Offer.find(offer_id)
        o.approve if approve
        o.delete if delete
        count += 1
      end
    end
    
    redirect_to '/deals_and_extras/admin', :notice => "Updated #{count} Offers"
  end

end
