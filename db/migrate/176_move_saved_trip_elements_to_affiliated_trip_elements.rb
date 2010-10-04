class MoveSavedTripElementsToAffiliatedTripElements < ActiveRecord::Migration

  def self.up
    execute("insert into affiliated_trip_elements (affiliate_type,affiliate_id,trip_element_id,position)
      select 'Profile', s1.profile_id, s1.trip_element_id, count(1) from saved_trip_elements s1
      join saved_trip_elements s2 on s1.profile_id=s2.profile_id and s1.id>=s2.id group by s1.profile_id, s1.id")
    drop_table :saved_trip_elements
    
    add_column :profiles, :affiliated_trip_elements_count, :integer, :null => false, :default => 0
  end
  
  def self.down
  end

end