class CreateOfferAttributeTable < ActiveRecord::Migration
  def self.up
    create_table :offer_attributes do |t|
      t.timestamps
      
      t.integer :offer_id
      t.integer :attribute_id
      t.string :attribute
    end
  end

  def self.down
  end
end
