class AddArchiveToTrips < ActiveRecord::Migration

  def self.up
    add_column :trips, :archived, :boolean, :default => false
    add_index :trips, :archived
  end

  def self.down
    remove_column :trips, :archived
  end

end