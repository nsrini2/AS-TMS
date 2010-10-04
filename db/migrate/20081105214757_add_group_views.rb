class AddGroupViews < ActiveRecord::Migration
  def self.up
    add_column :groups, :views, :integer, :default => 0
  end

  def self.down
    remove_column :groups, :views
  end
end
