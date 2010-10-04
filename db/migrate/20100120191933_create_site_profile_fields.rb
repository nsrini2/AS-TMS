class CreateSiteProfileFields < ActiveRecord::Migration
  def self.up
    create_table :site_profile_fields do |t|
      t.string :label
      t.string :question
      t.boolean :completes_profile, :default => true
      t.boolean :matchable, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :site_profile_fields
  end
end
