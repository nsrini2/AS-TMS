class AlterTableSiteConfigAddWelcomePromos < ActiveRecord::Migration
  def self.up
    add_column :site_configs, :welcome_promo_title_1, :string, :default => ""
    add_column :site_configs, :welcome_promo_1, :string, :default => ""
    add_column :site_configs, :welcome_promo_title_2, :string, :default => ""
    add_column :site_configs, :welcome_promo_2, :string, :default => ""
    add_column :site_configs, :welcome_promo_title_3, :string, :default => ""
    add_column :site_configs, :welcome_promo_3, :string, :default => ""
  end

  def self.down
    remove_column :site_configs, :welcome_promo_title_1
    remove_column :site_configs, :welcome_promo_1
    remove_column :site_configs, :welcome_promo_title_2
    remove_column :site_configs, :welcome_promo_2
    remove_column :site_configs, :welcome_promo_title_3
    remove_column :site_configs, :welcome_promo_3
  end
end
