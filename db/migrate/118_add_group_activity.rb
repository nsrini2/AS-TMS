class AddGroupActivity < ActiveRecord::Migration
  def self.up
    add_column :groups, :activity_points, :integer, :null => false, :default => 0
    add_column :groups, :activity_status, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :groups, :activity_points
    remove_column :groups, :activity_status
  end
end