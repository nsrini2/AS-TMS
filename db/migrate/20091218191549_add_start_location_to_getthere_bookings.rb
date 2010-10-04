class AddStartLocationToGetthereBookings < ActiveRecord::Migration
  def self.up
    add_column :getthere_bookings, :start_location, :string
  end

  def self.down
    remove_column :getthere_bookings, :start_location
  end
end
