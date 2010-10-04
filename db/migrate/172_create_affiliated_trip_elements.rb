class CreateAffiliatedTripElements < ActiveRecord::Migration
  def self.up
  	create_table :affiliated_trip_elements do |t|
      t.string :affiliate_type, :null => false
      t.integer :affiliate_id, :null => false
      t.integer :trip_element_id, :null => false
      t.integer :position, :null => false
    end
	    
	execute("insert into affiliated_trip_elements (affiliate_type,affiliate_id,trip_element_id,position) select 'Trip', trip_id, trip_element_id, position from trip_element_members")
	    
    drop_table :trip_element_members
    
	add_index :affiliated_trip_elements, [:trip_element_id,:affiliate_type], :name => 'tei_at'
    add_index :affiliated_trip_elements, [:affiliate_type,:affiliate_id,:trip_element_id], :unique => true, :name => 'at_ai_tei'
    add_index :affiliated_trip_elements, [:affiliate_type,:affiliate_id,:position], :unique => true, :name => 'at_ai_p'
  end

  def self.down
    raise 'cant go back'
  end
end