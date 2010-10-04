class EditScreenNameIndex < ActiveRecord::Migration

  def self.up
    remove_index :users, :screen_name
    add_index :users, :screen_name
  end

  def self.down
    remove_index :users, :screen_name
    add_index :users, :screen_name, :unique => true
  end

end
