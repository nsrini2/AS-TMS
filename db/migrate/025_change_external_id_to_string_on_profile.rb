class ChangeExternalIdToStringOnProfile < ActiveRecord::Migration
  
  def self.up
    change_column :profiles, :external_id, :string
    add_index :profiles, :external_id
  end

  def self.down
    remove_column :profiles, :external_id
    add_column :profiles, :external_id, :integer
  end
  
end