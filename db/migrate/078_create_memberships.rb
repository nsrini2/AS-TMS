class CreateMemberships < ActiveRecord::Migration
  def self.up
      create_table :memberships do |t|
        t.column :profile_id, :integer, :null => false
        t.column :group_id, :integer, :null => false
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
    end
  end

  def self.down
     drop_table :memberships
  end
end