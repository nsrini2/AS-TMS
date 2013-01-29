class AddModeratorToGroupMemberships < ActiveRecord::Migration
  def self.up
    add_column :group_memberships, :moderator, :boolean, :null => false, :default => false
    add_column :groups, :owner_id, :integer
    
    execute "update groups g join group_memberships gm on g.id=gm.group_id set g.owner_id=gm.profile_id"
    
    add_index :group_memberships, :moderator
  end

  def self.down
    remove_column :group_memberships, :moderator
    remove_column :groups, :owner_id
  end
end
