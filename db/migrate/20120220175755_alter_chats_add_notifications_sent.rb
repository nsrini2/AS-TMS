class AlterChatsAddNotificationsSent < ActiveRecord::Migration
  def self.up
    add_column :chats, :notifications_sent, :integer, :default => false
  end

  def self.down
    drop_column :chats, :notifications_sent    
  end
end
