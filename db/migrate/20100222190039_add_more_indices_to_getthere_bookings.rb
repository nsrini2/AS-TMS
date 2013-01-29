class AddMoreIndicesToGetthereBookings < ActiveRecord::Migration
  def self.up
    add_index :getthere_bookings, :public
    
    add_index :getthere_bookings, :start_location
    add_index :getthere_bookings, :start_airport_code
    add_index :getthere_bookings, :locations
    add_index :getthere_bookings, :destination_airport_codes
  end

  def self.down
    remove_index :getthere_bookings, :public    
    
    remove_index :getthere_bookings, :start_location
    remove_index :getthere_bookings, :start_airport_code
    remove_index :getthere_bookings, :locations
    remove_index :getthere_bookings, :destination_airport_codes
  end
end
