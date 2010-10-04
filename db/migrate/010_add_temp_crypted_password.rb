class AddTempCryptedPassword < ActiveRecord::Migration
  def self.up
    add_column :profiles, :temp_crypted_password, :string, :limit => 40
  end
  
  def self.down
    remove_column :profiles, :temp_crypted_password
  end
end
