class LocationType < ActiveRecord::Base
  
  has_many :locations
  
  def self.OPTIONIZE
    self.all.collect do |l|
      [l.location_type, l.id]
    end
  end
  
end