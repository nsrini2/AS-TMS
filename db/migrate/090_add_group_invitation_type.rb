class AddGroupInvitationType < ActiveRecord::Migration
  def self.up
    add_column :group_invitations, :type, :string
    execute 'update group_invitations set type="GroupInvitation"'
    change_column :group_invitations, :type, :string, :null => false
    add_index :group_invitations, :type
  end

  def self.down
    remove_column :group_invitations, :type
  end

end
