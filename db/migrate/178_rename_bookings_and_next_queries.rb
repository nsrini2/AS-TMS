class RenameBookingsAndNextQueries < ActiveRecord::Migration
  def self.up
    rename_table :bookings, :getthere_bookings
    rename_table :next_queries, :getthere_next_queries
  end

  def self.down
    rename_table :getthere_bookings, :bookings
    rename_table :getthere_next_queries, :next_queries
  end
end