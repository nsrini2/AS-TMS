class AddNoMembersAt < ActiveRecord::Migration

  def self.up
    add_column :groups, :no_memberships_on, :date
    add_index :groups, :group_memberships_count
    execute 'update groups set no_memberships_on=curdate() where group_memberships_count=0'
    add_index :groups, :no_memberships_on
  end

  def self.down
    remove_column :groups, :no_memberships_on
    remove_index :groups, :group_memberships_count
  end

end
