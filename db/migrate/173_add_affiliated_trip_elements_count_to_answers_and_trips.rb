class AddAffiliatedTripElementsCountToAnswersAndTrips < ActiveRecord::Migration
  
  def self.up
    add_column :answers, :affiliated_trip_elements_count, :integer, :null => false, :default => 0
    add_column :trips, :affiliated_trip_elements_count, :integer, :null => false, :default => 0
  end
  
  def self.down
  	remove_column :answers, :affiliated_trip_elements_count
  	remove_column :trips, :affiliated_trip_elements_count
  end
  
end