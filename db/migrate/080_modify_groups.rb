class ModifyGroups < ActiveRecord::Migration
  def self.up

    add_index :groups, :name, :unique => true
    add_index :groups, :created_at

    # rename memberships
    drop_table :memberships
    create_table :group_memberships do |t|
      t.column :profile_id, :integer, :null => false
      t.column :group_id, :integer, :null => false
      t.column :created_at, :datetime
    end
    add_index :group_memberships, [:group_id,:profile_id], :unique => true
    add_index :group_memberships, :profile_id
    add_index :group_memberships, :created_at

  end

  def self.down
    drop_table :group_memberships
    create_table :memberships
  end
end
