require 'ym4r/google_maps/geocoding'
include Ym4r::GoogleMaps

class Location < ActiveRecord::Base
  
  has_and_belongs_to_many :offers
  belongs_to :state_province
  belongs_to :location_type
  belongs_to :country
  
  serialize :location_data
  
  #default_scope :order => 'description'
  
  scope :distinct_cities, lambda{
    select('DISTINCT city').where('city IS NOT NULL').order('city')
  }
  
  def international?
    self.state_province_id.to_i <= 0
  end
  
  def update_latlon

    # Old ym4r way...
    # results = Geocoding::get(description)
    # if results.status == Geocoding::GEO_SUCCESS
    #   self.location_data = results[0]
    #   self.latitude = results[0].latitude
    #   self.longitude = results[0].longitude
    #   self.city = results[0].locality || results[0].sub_administrative_area
    #   self.state_province = StateProvince.find_by_abbreviation(results[0].administrative_area) rescue nil
    #   self.country = Country.find_or_create_by_abbreviation(results[0].country_code) rescue nil
    # end
    
    # New MapQuest way
    begin
      results = RestClient.get "https://www.mapquestapi.com/geocoding/v1/address?key=#{Setting.map_quest_api_key}&location=#{URI.encode(description)}&maxResults=1"
      j_results = JSON.parse(results)
      if result = j_results["results"].first
        puts result.inspect
        self.location_data =  result["locations"].first
        self.latitude = location_data["latLng"]["lat"]
        self.longitude = location_data["latLng"]["lng"]
        self.city = location_data["adminArea5"]
        self.state_province = StateProvince.find_by_abbreviation(location_data["adminArea3"]) rescue nil
        self.country = Country.find_or_create_by_abbreviation(location_data["adminArea1"]) rescue nil
      end
      self.save      
    rescue
      message = "Could not get lat long for Location #{self.id}: #{$!}"
      puts message
      Rails.logger.fatal message
      
      false
    end
  end
  alias update_latlng update_latlon
  
  def self.OPTIONIZE
    self.all.collect do |l|
      [l.description, l.id]
    end
  end
  
  def self.cities
    cities = []
    self.distinct_cities.each do |c|
      cities.push(c.city)
    end
    cities
  end
  
  # TODO: This is horribly inefficient
  def self.active_cities
    cities = []
    offers = Offer.approved.not_deleted.active.includes(:locations)
    offers.each do |o|
      cities << o.location.city
    end
    cities.reject{ |c| c.blank? }.uniq.collect{ |c| c.strip.titlecase }.sort
  end
  
end