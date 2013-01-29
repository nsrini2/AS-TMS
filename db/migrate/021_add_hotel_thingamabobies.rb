class AddHotelThingamabobies < ActiveRecord::Migration
  def self.up
    create_table :hotels do |t|
      t.column :tvly_hotel_id, :integer
      t.column :name, :string
    end
    add_column :questions, :hotel_id, :integer
    add_column :answers, :location_id, :integer
    add_column :answers, :hotel_id, :integer
  end

  def self.down
    drop_table :hotels
    remove_column :questions, :hotel_id
    remove_column :answers, :location_id
    remove_column :answers, :hotel_id
  end
end
