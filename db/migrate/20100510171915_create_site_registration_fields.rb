class CreateSiteRegistrationFields < ActiveRecord::Migration
  def self.up
    create_table :site_registration_fields do |t|
      t.string :label
      t.string :field
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :site_registration_fields
  end
end
