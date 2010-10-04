class AddApiKeyToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :api_key, :string, :default => nil
    add_index :profiles, :api_key
  end

  def self.down
    remove_column :profiles, :api_key
  end
end
