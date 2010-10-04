class AddLastUpdatedByToTripElements < ActiveRecord::Migration
  def self.up
    add_column :trip_elements, :last_updated_by, :integer, :null => false
    execute "Update trip_elements set last_updated_by = (select id from profiles limit 1)"
  end

  def self.down
    remove_column :trip_elements, :last_updated_by
  end
end