class RemoveArchiveFromTrips < ActiveRecord::Migration
  def self.up
    remove_column :trips, :archived
  end

  def self.down
    add_column :trips, :archived, :boolean, :default => false
    add_index :trips, :archived
  end
end
