class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :host_id
      t.string :title
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :started_at
      t.datetime :ended_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :chats
  end
end
