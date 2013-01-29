class StartTrips < ActiveRecord::Migration

  def self.up

    drop_table :trips

    create_table :trips do |t|

      t.datetime :created_at, :null => false

      t.integer :profile_id, :null => false
      t.string :name, :null => false
      t.string :location
      t.string :trip_type, :null => false
      t.text :notes

      t.boolean :public_viewable, :default => false, :null => false

      t.decimal :bbox_ne_lat, :bbox_ne_lon, :bbox_sw_lat, :bbox_sw_lon, :decimal, :precision => 13, :scale => 10
      t.decimal :bbox_ctr_lat, :bbox_ctr_lon, :precision => 13, :scale => 10

    end

    add_index :trips, :created_at
    add_index :trips, :profile_id
    add_index :trips, :trip_type
    add_index :trips, :public_viewable
    add_index :trips, [:bbox_ctr_lat,:bbox_ctr_lon]

    create_table :trip_elements do |t|

      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false

      t.string :element_type, :null => false
      t.string :name, :null => false

      t.string :loc_name

      t.decimal :loc_lat, :loc_lng, :decimal, :precision => 13, :scale => 10

      t.string :loc_address1
      t.string :loc_address2
      t.string :loc_city
      t.string :loc_state
      t.string :loc_zip
      t.string :loc_country

      t.string :url
      t.string :photo_url

    end

    add_index :trip_elements, :element_type
    add_index :trip_elements, :name  # auto-suggest
    add_index :trip_elements, [:loc_lat,:loc_lng]

    create_table :trip_element_members do |t|
      t.integer :trip_id, :null => false
      t.integer :trip_element_id, :null => false
      t.integer :position, :null => false
    end

    add_index :trip_element_members, [:trip_id,:position], :unique => true
    add_index :trip_element_members, :trip_element_id

  end

  def self.down
    drop_table :trip_elements
    drop_table :trip_element_members
  end

end
