class CreateSupplierType < ActiveRecord::Migration
  def self.up
    create_table :supplier_types do |t|
      t.timestamps
      
      t.string :supplier_type
    end
  end

  def self.down
  end
end
