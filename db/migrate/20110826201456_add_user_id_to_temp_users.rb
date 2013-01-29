class AddUserIdToTempUsers < ActiveRecord::Migration
  def self.up
    add_column :temp_users, :user_id, :integer
  end

  def self.down
    remove_column :temp_users, :user_id
  end
end
