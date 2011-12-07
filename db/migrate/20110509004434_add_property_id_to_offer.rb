class AddPropertyIdToOffer < ActiveRecord::Migration
  def self.up
    add_column :offers, :property_id, :string
  end

  def self.down
    remove_column :offers, :property_id
  end
end
