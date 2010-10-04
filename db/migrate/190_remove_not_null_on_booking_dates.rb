class RemoveNotNullOnBookingDates < ActiveRecord::Migration

  def self.up
    change_column :getthere_bookings, :start_time, :datetime, :null => true
	change_column :getthere_bookings, :end_time, :datetime, :null => true
  end

  def self.down
    change_column :getthere_bookings, :start_time, :datetime, :null => false
	change_column :getthere_bookings, :end_time, :datetime, :null => false
  end

end
