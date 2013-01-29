class AddDescriptionToPois < ActiveRecord::Migration

  def self.up
    add_column :pois, :description, :text
  end
  
  def self.down
    remove_column :pois, :description
  end

end