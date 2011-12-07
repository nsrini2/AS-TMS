class RootController < ApplicationController
  
  layout 'main'
  
  def index
    @show_status = false
    @user = current_user
    
    # Setup filters
    @offer_types = OfferType.all
    @cities = Location.active_cities
  end
  
end
