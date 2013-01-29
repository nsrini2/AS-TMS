class CreateOfferSupplierTable < ActiveRecord::Migration
  def self.up
    create_table :offers_suppliers, :id => false do |t|
      
      t.timestamp
      
      t.integer :offer_id
      t.integer :supplier_id
    end
  end

  def self.down
  end
end
