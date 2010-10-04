class AddImportedFlagToTripsAndTripElements < ActiveRecord::Migration
  def self.up
    add_column :trips, :imported, :boolean, :default => false, :null => false
    add_column :trip_elements, :imported, :boolean, :default => false, :null => false

    add_index :trips, :imported
    add_index :trip_elements, :imported
  end

  def self.down
    remove_column :trips, :imported
    remove_column :trip_elements, :imported
  end
end
