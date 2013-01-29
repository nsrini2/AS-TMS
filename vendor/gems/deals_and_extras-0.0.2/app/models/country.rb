require 'ym4r/google_maps/geocoding'
include Ym4r::GoogleMaps

class Country < ActiveRecord::Base

  has_many :locations

  # after_create :update_data

  validates_uniqueness_of :name, :cctld_code, :srw_country_code

  serialize :location_data
  
  def abbreviation
    # the code that calls this is actually looking for the Country Code Top Level Domain (ccTLD)
    cctld || srw_country_code
  end
  
  def country
    name
  end

  def update_data
    results = Geocoding::get(cctld || name)
    if results.status == Geocoding::GEO_SUCCESS
      self.name = results[0].address
      self.cctld = results[0].country_code
      self.location_data = results[0]
    end
    self.save
  end

  def self.OPTIONIZE
    self.all.collect do |c|
      [c.name, c.id]
    end
  end

end