class AddFrozenEmailsToSiteConfigs < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :frozen_emails, :boolean, :default => false
  end

  def self.down
    remove_column :site_configs, :frozen_emails
  end
end
