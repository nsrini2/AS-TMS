class AlterChats2 < ActiveRecord::Migration
  def self.up
    add_column :chats, :start_at, :datetime
    remove_column :chats, :start_date
    remove_column :chats, :start_time
  end

  def self.down
    remove_column :chats, :start_at
    add_column :chats, :start_date, :date
    add_column :chats, :start_time, :time
  end
end
