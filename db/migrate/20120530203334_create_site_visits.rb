class CreateSiteVisits < ActiveRecord::Migration
  def self.up
    create_table :site_visits do |t|
      t.integer :profile_id
      t.integer :julian_date

      t.timestamps
    end
  end

  def self.down
    drop_table :site_visits
  end
end
