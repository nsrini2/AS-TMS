class AddPublicToGetthereBookings < ActiveRecord::Migration
  def self.up
    add_column :getthere_bookings, :public, :boolean, :default => false
  end

  def self.down
    remove_column :getthere_bookings, :public
  end
end
