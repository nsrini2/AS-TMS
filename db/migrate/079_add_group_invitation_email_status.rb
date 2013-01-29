class AddGroupInvitationEmailStatus < ActiveRecord::Migration
  def self.up
    add_column :profiles, :group_invitation_email_status, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :group_invitation_email_status
  end
end