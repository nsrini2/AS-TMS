class TempPasswordExpiresAt < ActiveRecord::Migration
  def self.up
    add_column :users, :temp_crypted_password_expires_at, :datetime
  end

  def self.down
    remove_column :users, :temp_crypted_password_expires_at
  end
end
