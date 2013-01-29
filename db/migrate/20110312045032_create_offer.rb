class CreateOffer < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.timestamps
      t.integer :offer_type_id
      t.date :start_date
      t.date :end_date
      t.string :hotel_chain_code
      t.string :hotel_property_id
      t.string :destination_airport_code
      t.integer :state_id
      t.integer :destination_country
      t.string :property_name
      t.string :address
      t.string :address2
      t.string :address3
      t.string :lat
      t.string :long
      t.string :city
      t.integer :zip
      t.string :description
      t.string :ad_text

      t.boolean :is_approved, :default => false
      t.datetime :approved_at

      t.boolean :is_deleted, :default => false
      t.datetime :deleted_at
    end
  end

  def self.down
  end
end
