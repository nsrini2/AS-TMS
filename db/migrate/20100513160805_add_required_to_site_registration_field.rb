class AddRequiredToSiteRegistrationField < ActiveRecord::Migration
  def self.up
    add_column :site_registration_fields, :required, :boolean, :default => true
  end

  def self.down
    remove_column :site_registration_fields, :required
  end
end
