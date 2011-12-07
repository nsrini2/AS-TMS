class CreateLocationTable < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.timestamps
      
      t.string :description
      t.integer :location_type_id
      t.string :latitude
      t.string :longitude
      t.integer :state_province_id
      t.integer :country_id
    end
  end

  def self.down
  end
end
