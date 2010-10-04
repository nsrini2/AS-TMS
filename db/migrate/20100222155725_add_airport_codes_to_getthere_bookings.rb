class AddAirportCodesToGetthereBookings < ActiveRecord::Migration
  def self.up
    add_column :getthere_bookings, :start_airport_code, :string
    add_column :getthere_bookings, :destination_airport_codes, :string
  end

  def self.down
    remove_column :getthere_bookings, :start_airport_code
    remove_column :getthere_bookings, :destination_airport_codes
  end
end
