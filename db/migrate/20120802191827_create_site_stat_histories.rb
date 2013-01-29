class CreateSiteStatHistories < ActiveRecord::Migration
  def self.up
    create_table :site_stat_histories do |t|
      t.integer :julian_date
      t.string  :name
      t.string  :value
      t.timestamps
    end
    add_index :site_stat_histories, [:julian_date, :name],  :unique => true
  end

  def self.down
    drop_table :site_stat_histories
  end
end
