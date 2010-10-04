class AddImportedToPoiLists < ActiveRecord::Migration
  def self.up
    add_column :poi_lists, :imported, :boolean, :default => false
    add_index :poi_lists, :imported
  end

  def self.down
    remove_column :poi_lists, :imported
  end
end
