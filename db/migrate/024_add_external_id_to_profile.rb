class AddExternalIdToProfile < ActiveRecord::Migration
  
  def self.up
    add_column :profiles, :external_id, :integer
  end

  def self.down
    remove_column :profiles, :external_id
  end
  
end