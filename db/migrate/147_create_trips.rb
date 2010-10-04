class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.timestamps
      t.string :name, :null => false
      t.string :location, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false
      t.string :trip_type, :null => false
      t.text :notes
      t.integer :profile_id, :null => false
    end
    add_index :trips, :name
    add_index :trips, :location
    add_index :trips, :created_at
    add_index :trips, :start_time
    add_index :trips, :end_time
    add_index :trips, :trip_type 
    add_index :trips, :profile_id
  end

  def self.down
    drop_table :trips
  end
end
