class AlterChats < ActiveRecord::Migration
  def self.up
    add_column :chats, :description, :text
  end

  def self.down
    remove_column :chats, :description
  end
end
