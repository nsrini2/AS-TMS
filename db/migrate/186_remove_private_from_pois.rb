class RemovePrivateFromPois < ActiveRecord::Migration
  def self.up
    remove_column :pois, :private
  end

  def self.down
    add_column :pois, :private, :boolean, :default => false
    add_index :pois, :private
  end
end
