class CreateSiteConfigs < ActiveRecord::Migration
  def self.up
    create_table :site_configs do |t|
      t.string :site_name
      t.string :disclaimer
      t.boolean :terms_acceptance_required, :default => true
      t.boolean :open_registration, :default => true
      t.boolean :registration_queue, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :site_configs
  end
end
