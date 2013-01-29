class AddLocationStuff < ActiveRecord::Migration
  def self.up
  create_table :locations do |t|
      t.column :geoname_id, :integer
      t.column :name, :string
    end
    add_column :questions, :location_id, :integer
  end

  def self.down
    drop_table :locations
    remove_column :questions, :location_id
  end
end
