class AddPrivateElements < ActiveRecord::Migration

  def self.up
    add_column :trip_elements, :private, :boolean, :default => false
    add_index :trip_elements, :private
  end

  def self.down
    remove_column :trip_elements, :private
  end

end