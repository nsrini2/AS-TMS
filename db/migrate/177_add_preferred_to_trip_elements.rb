class AddPreferredToTripElements < ActiveRecord::Migration
  def self.up
    add_column :trip_elements, :preferred, :boolean, :default => false
  end

  def self.down
    remove_column :trip_elements, :preferred
  end
end