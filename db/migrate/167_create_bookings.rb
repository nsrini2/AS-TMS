class CreateBookings < ActiveRecord::Migration
  def self.up
    create_table :bookings do |t|
      t.timestamps
      t.string :site_name, :null => false
      t.string :ord_key, :null => false
      t.string :user_login, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false
      t.text :xml, :null => false
    end
    add_index :bookings, :site_name
    add_index :bookings, :ord_key
    add_index :bookings, :user_login
    add_index :bookings, :start_time
    add_index :bookings, :end_time
    
    create_table :next_queries do |t|
      t.timestamps
      t.string :site_name, :null => false
      t.string :request_type, :null => false
      t.string :start_id
    end
    add_index :next_queries, :site_name
    add_index :next_queries, :request_type
  end

  def self.down
    drop_table :bookings
    drop_table :next_queries
  end
end