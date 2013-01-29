class AddSavedTripElements < ActiveRecord::Migration

  def self.up

    # fix for old bad migration syntax
    remove_column :trips, :decimal
    remove_column :trip_elements, :decimal

    add_index :trip_element_members, [:trip_id, :trip_element_id], :unique => true

    create_table :saved_trip_elements do |t|
      t.datetime :created_at, :null => false
      t.integer :profile_id, :trip_element_id, :null => false
    end
    add_index :saved_trip_elements, [:profile_id, :trip_element_id], :unique => true

  end

  def self.down

    drop_table :saved_trip_elements

    add_column :trips, :decimal, :decimal
    add_column :trip_elements, :decimal, :decimal

    remove_index :trip_element_members, [:trip_id, :trip_element_id]

  end
end
