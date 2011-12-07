class CreateOfferLocation < ActiveRecord::Migration
  def self.up
    create_table :locations_offers, :id => false do |t|
      t.timestamps
      
      t.integer :offer_id
      t.integer :location_id
    end
  end

  def self.down
  end
end
