class RemoveNumMembersFromGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups, :num_members
  end

  def self.down
    add_column :groups, :num_members, :integer
  end
end
