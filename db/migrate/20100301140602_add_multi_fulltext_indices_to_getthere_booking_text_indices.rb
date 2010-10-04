class AddMultiFulltextIndicesToGetthereBookingTextIndices < ActiveRecord::Migration
  def self.up
    execute "CREATE FULLTEXT INDEX fulltext_getthere_booking_departures on getthere_booking_text_indices (start_location_text, start_airport_code_text)"
    execute "CREATE FULLTEXT INDEX fulltext_getthere_booking_arrivals on getthere_booking_text_indices (locations_text, destination_airport_codes_text)"
  end

  def self.down
  end
end
