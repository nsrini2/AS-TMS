class AddSiteProfileFieldIdToSiteRegistrationFields < ActiveRecord::Migration
  def self.up
    add_column :site_registration_fields, :site_profile_field_id, :integer
  end

  def self.down
    remove_column :site_registration_fields, :site_profile_field_id
  end
end
