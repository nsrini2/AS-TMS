class CreateSiteProfileCards < ActiveRecord::Migration
  def self.up
    create_table :site_profile_cards do |t|
      t.integer :site_profile_field_id
      t.integer :position
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :site_profile_cards
  end
end
