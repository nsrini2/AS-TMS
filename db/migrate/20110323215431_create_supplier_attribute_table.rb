class CreateSupplierAttributeTable < ActiveRecord::Migration
  def self.up
    create_table :supplier_attributes do |t|
      t.timestamps
      
      t.integer :supplier_id
      t.integer :attribute_id
      t.string :attribute
    end
  end

  def self.down
  end
end
