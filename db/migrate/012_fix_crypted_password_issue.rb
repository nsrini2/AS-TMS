class FixCryptedPasswordIssue < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :temp_crypted_password
    add_column :users, :temp_crypted_password, :string, :limit => 40
  end
  
  def self.down
    add_column :profiles, :temp_crypted_password, :string, :limit => 40
    remove_column :users, :temp_crypted_password
  end
end
