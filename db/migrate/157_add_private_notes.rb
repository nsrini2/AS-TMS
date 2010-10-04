class AddPrivateNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :private, :boolean, :default => false
    add_index :notes, :private
  end

  def self.down
    remove_column :notes, :private
  end
end
