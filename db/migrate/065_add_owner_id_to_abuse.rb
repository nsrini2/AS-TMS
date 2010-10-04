class AddOwnerIdToAbuse < ActiveRecord::Migration
  def self.up
    add_column :abuses, :owner_id, :integer
  end

  def self.down
    remove_column :abuses, :owner_id
  end
end
