class AddRowDataToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :location_data, :blob
  end

  def self.down
  end
end
