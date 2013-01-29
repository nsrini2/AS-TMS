class AddDefaultNoteToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :is_default, :boolean
  end

  def self.down
    remove_column :notes, :is_default
  end
end