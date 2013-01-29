class AddProfileToAbuse < ActiveRecord::Migration
  def self.up
    add_column :abuses, :profile_id, :integer
  end
  def self.down
    remove_column :abuses, :profile_id
  end
end
