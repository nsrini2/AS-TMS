class AddCreatedByToTripElements < ActiveRecord::Migration

  def self.up
    add_column :trip_elements, :created_by, :integer, :null => false
    add_index :trip_elements, :created_by
    execute "update trip_elements set created_by = last_updated_by"
  end

  def self.down
    remove_column :trip_elements, :created_by
  end

end