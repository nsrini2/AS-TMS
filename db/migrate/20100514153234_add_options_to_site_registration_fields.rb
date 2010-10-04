class AddOptionsToSiteRegistrationFields < ActiveRecord::Migration
  def self.up
    add_column :site_registration_fields, :options, :text
  end

  def self.down
    remove_column :site_registration_fields, :options
  end
end
