class CreateGetthereBookingTextIndices < ActiveRecord::Migration
  def self.up
    create_table :getthere_booking_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :getthere_booking_id, :integer, :null => false
      t.column :start_location_text, :text
      t.column :locations_text, :text
      t.column :start_airport_code_text, :text
      t.column :destination_airport_codes_text, :text
      t.timestamps
    end
    
    add_index :getthere_booking_text_indices, :getthere_booking_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_getthere_booking on getthere_booking_text_indices (start_location_text, locations_text, start_airport_code_text, destination_airport_codes_text)"
  end

  def self.down
    drop_table :getthere_booking_text_indices
  end
end
