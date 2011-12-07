class AlterChat < ActiveRecord::Migration
  def self.up
    remove_column :chats, :end_at
    add_column :chats, :duration, :integer
    remove_column :chats, :start_at
    add_column :chats, :start_date, :date
    add_column :chats, :start_time, :time
  end

  def self.down
    remove_column :chats, :duration
    add_column :chats, :end_at, :datetime
    remove_column :chats, :start_at
    add_column :chats, :start_at, :datetime
    remove_column :chats, :start_time
  end
end
