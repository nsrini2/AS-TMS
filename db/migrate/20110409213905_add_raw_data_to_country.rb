class AddRawDataToCountry < ActiveRecord::Migration
  def self.up
    add_column :countries, :location_data, :blob
  end

  def self.down
  end
end
