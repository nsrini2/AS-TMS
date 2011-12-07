class ChangeSiteRegistrationFieldRequiredToIsRequired < ActiveRecord::Migration
  def self.up
    rename_column :site_registration_fields, :field, :field_name
  end

  def self.down
    rename_column :site_registration_fields, :field_name, :field
  end
end
