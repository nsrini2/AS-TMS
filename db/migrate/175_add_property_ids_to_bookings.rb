class AddPropertyIdsToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :property_ids, :string
  end

  def self.down
    remove_column :bookings, :property_ids
  end
end