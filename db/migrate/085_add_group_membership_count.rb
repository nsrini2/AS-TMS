class AddGroupMembershipCount < ActiveRecord::Migration
  def self.up
    add_column :groups, :group_memberships_count, :integer, :null => false, :default => 0

  end

  def self.down
    remove_column :groups, :group_memberships_count
  end
end
