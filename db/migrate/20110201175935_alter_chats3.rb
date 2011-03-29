class AlterChats3 < ActiveRecord::Migration
  def self.up
    add_column :chats, :active, :integer, :default => 1
  end

  def self.down
    remove_column :chats, :active
  end
end
