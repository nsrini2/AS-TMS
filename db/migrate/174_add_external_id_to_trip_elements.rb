class AddExternalIdToTripElements < ActiveRecord::Migration
  def self.up
    add_column :trip_elements, :external_id, :string
    add_index :trip_elements, :external_id
  end

  def self.down
    remove_column :trip_elements, :external_id
  end
end