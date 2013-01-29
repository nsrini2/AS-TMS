class MapsController < ApplicationController
  layout nil
  
  def index
    ids = params["p"].to_s.split(',')
    @offers = Offer.find(ids)
    @offers.find_all do |o|
      !o.locations[0].latitude.nil? && !o.locations[0].longitude.nil?
    end
  end
  
end
