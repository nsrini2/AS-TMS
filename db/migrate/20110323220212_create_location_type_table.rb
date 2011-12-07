class CreateLocationTypeTable < ActiveRecord::Migration
  def self.up
    create_table :location_types do |t|
      t.timestamps
      
      t.string :location_type
    end
  end

  def self.down
  end
end
