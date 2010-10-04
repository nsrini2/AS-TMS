class DropLocationHotel < ActiveRecord::Migration
  def self.up
    drop_table :hotels
    drop_table :locations
    remove_column :questions, :location_id
    remove_column :questions, :hotel_id
    remove_column :answers, :location_id
    remove_column :answers, :hotel_id

  end

  def self.down
  end
end
