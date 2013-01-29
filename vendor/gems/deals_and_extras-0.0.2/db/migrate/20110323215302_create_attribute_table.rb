class CreateAttributeTable < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.timestamps
      
      t.string :description
    end
  end

  def self.down
  end
end
