class FiltersController < ApplicationController
  layout nil

  def index
    @offer_types = OfferType.all
    @cities = Location.active_cities # Location.cities rescue []
  end
  
  def sort
  end
  
end
