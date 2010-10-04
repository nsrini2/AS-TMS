class AddSiteConfigFields < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :viewable_karma, :boolean, :default => true
    add_column :site_configs, :user_max, :integer, :default => 0
    add_column :site_configs, :feedback_email, :string
    add_column :site_configs, :email_from_address, :string
    add_column :site_configs, :analytics_tracker_code, :string
    add_column :site_configs, :site_base_url, :string
    add_column :site_configs, :api_enabled, :boolean, :default => false
    add_column :site_configs, :rank_enabled, :boolean, :default => false
    add_column :site_configs, :monitor_email_address, :string
  end

  def self.down
    remove_column :site_configs, :viewable_karma
    remove_column :site_configs, :user_max
    remove_column :site_configs, :feedback_email
    remove_column :site_configs, :email_from_address
    remove_column :site_configs, :analytics_tracker_code
    remove_column :site_configs, :site_base_url
    remove_column :site_configs, :api_enabled
    remove_column :site_configs, :rank_enabled
    remove_column :site_configs, :monitor_email_address
  end
end
