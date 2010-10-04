class CreateGroupInvitations < ActiveRecord::Migration
  def self.up
    create_table :group_invitations do |t|
      t.column :group_id, :integer
      t.column :receiver_id, :integer
      t.column :sender_id, :integer
      t.column :created_at, :datetime, :null => false
    end

    add_index :group_invitations, :group_id
    add_index :group_invitations, :receiver_id
    add_index :group_invitations, :sender_id
    add_index :group_invitations, :created_at
  end

  def self.down
    drop_table :group_invitations
  end
end
