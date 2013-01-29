class AddPrivateFlagToLists < ActiveRecord::Migration
  def self.up
    add_column :poi_lists, :private, :boolean, :default => false
    add_index :poi_lists, :private
  end

  def self.down
    remove_column :poi_lists, :private
  end
end
