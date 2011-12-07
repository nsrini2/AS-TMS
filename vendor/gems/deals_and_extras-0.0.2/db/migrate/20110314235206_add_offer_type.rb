class AddOfferType < ActiveRecord::Migration
  def self.up
    
    create_table :offer_types do |t|
      t.timestamps
      t.string :offer_type
    end
    
  end

  def self.down
  end
end
