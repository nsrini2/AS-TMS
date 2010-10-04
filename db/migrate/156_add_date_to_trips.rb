class AddDateToTrips < ActiveRecord::Migration

  def self.up
    add_column :trips, :start_date, :datetime
    add_column :trips, :end_date, :datetime
    add_index :trips, [:start_date,:end_date]
  end

  def self.down
    remove_column :trips, :start_date
    remove_column :trips, :end_date
  end

end