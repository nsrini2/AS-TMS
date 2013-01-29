class AddUserPriorPasswords < ActiveRecord::Migration

  def self.up
    add_column :users, :crypted_password_history, :text
    change_column :users, :password_changed_at, :datetime, :null => true
  end

  def self.down
    remove_column :users, :crypted_password_history
  end
  
end
