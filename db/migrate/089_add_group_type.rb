class AddGroupType < ActiveRecord::Migration
  def self.up
    add_column :groups, :group_type, :integer, :null => false, :default => 0
    add_index :groups, :group_type
  end

  def self.down
    remove_column :groups, :group_type
  end
end
