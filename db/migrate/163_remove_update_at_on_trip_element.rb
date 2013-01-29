class RemoveUpdateAtOnTripElement < ActiveRecord::Migration
  def self.up
    add_column :trip_elements, :last_updated_at, :datetime, :null => false
    execute "update trip_elements set last_updated_at = updated_at"
    remove_column :trip_elements, :updated_at

  end

  def self.down
    add_column :trip_elements, :updated_at, :datetime, :null => false
    execute "update trip_elements set updated_at = last_updated_at"
    remove_column :trip_elements, :last_updated_at
  end
end
