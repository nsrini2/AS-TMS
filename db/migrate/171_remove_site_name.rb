class RemoveSiteName < ActiveRecord::Migration
    
  def self.up
    remove_column :bookings, :site_name
    remove_column :next_queries, :site_name
  end
    
  def self.down
  	add_column  :bookings, :site_name, :string, :null => false
  	add_index :bookings, :site_name
  	add_column  :next_queries, :site_name, :string, :null => false
	add_index :next_queries, :site_name
  end
    
end