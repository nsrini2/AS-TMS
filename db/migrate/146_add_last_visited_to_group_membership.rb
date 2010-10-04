class AddLastVisitedToGroupMembership < ActiveRecord::Migration

  def self.up
    add_column :group_memberships, :last_visited, :datetime
    execute 'update group_memberships set last_visited=now()'
  end

  def self.down
    remove_column :group_memberships, :last_visited
  end

end