require 'ym4r/google_maps/geocoding'
include Ym4r::GoogleMaps

class Country < ActiveRecord::Base

  has_many :locations

  # after_create :update_data

  validates_uniqueness_of :abbreviation, :country

  serialize :location_data

  def update_data
    results = Geocoding::get(abbreviation || country)
    if results.status == Geocoding::GEO_SUCCESS
      self.country = results[0].address
      self.abbreviation = results[0].country_code
      self.location_data = results[0]
    end
    self.save
  end

  def self.OPTIONIZE
    self.all.collect do |c|
      [c.country, c.id]
    end
  end

end