class ExpandActiveStatus < ActiveRecord::Migration

  def self.up
    remove_index :users, :active
    change_column :users, :active, :integer, :default => 1, :null => false
    add_index :users, :active
  end

end