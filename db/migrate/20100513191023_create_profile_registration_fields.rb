class CreateProfileRegistrationFields < ActiveRecord::Migration
  def self.up
    create_table :profile_registration_fields do |t|
      t.integer :profile_id
      t.integer :site_registration_field_id
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :profile_registration_fields
  end
end
