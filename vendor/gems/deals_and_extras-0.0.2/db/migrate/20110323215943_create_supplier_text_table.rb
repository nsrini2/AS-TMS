class CreateSupplierTextTable < ActiveRecord::Migration
  def self.up
    create_table :supplier_texts do |t|
      t.timestamps

      t.integer :supplier_id
      t.integer :text_type_id
      t.string :supplier_text
    end
  end

  def self.down
  end
end
