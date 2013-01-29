class CreateSupplierTable < ActiveRecord::Migration
  def self.up
    create_table :suppliers do |t|
      t.timestamps
      
      t.integer :supplier_type_id
      t.string :supplier_external_reference_id
      t.integer :data_source_id
      t.string :supplier_name
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :city
      t.string :state_province_id
      t.string :postal_code
      t.string :country_id
    end
  end

  def self.down
  end
end
