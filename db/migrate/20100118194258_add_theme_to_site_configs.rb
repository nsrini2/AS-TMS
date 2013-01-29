class AddThemeToSiteConfigs < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :theme, :string
  end

  def self.down
    remove_column :site_configs, :theme
  end
end
