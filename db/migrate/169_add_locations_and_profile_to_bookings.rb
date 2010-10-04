class AddLocationsAndProfileToBookings < ActiveRecord::Migration
    
  def self.up
    add_column :bookings, :locations, :string, :null => false
    remove_column :bookings, :user_login
    add_column :bookings, :profile_id, :integer, :null => false
    add_index :bookings, :profile_id
  end
    
  def self.down
  	add_column :bookings, :user_login, :string, :null => false
  	add_index :bookings, :user_login
  	remove_column :bookings, :profile_id
  	remove_column :bookings, :locations
  end
    
end