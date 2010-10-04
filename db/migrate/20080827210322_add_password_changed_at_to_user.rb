class AddPasswordChangedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :password_changed_at, :datetime, :null => false
    execute("update users set password_changed_at = now()")
  end

  def self.down
    remove_column :users, :password_changed_at
  end
end
