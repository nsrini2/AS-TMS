class Admin::DashboardController < AdminController

  def index
    
    @aside = 'layouts/admin/aside'
    @pending_offers = Offer.pending.not_deleted
    
  end

  

end
