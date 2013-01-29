class MakeNotesPoly < ActiveRecord::Migration
  def self.up
    remove_index :notes, :receiver_id
    add_column :notes, :receiver_type, :string, :null => false
    execute "update notes set receiver_type = 'Profile'"
    add_index :notes, [:receiver_type, :receiver_id]
  end

  def self.down
    execute "delete from notes where receiver_type = 'Group'"
    remove_index :notes, [:receiver_type, :receiver_id]
    remove_column :notes, :receiver_type
    add_index :notes, :receiver_id
  end
end
