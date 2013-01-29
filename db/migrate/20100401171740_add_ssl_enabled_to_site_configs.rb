class AddSslEnabledToSiteConfigs < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :ssl_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :site_configs, :ssl_enabled
  end
end
