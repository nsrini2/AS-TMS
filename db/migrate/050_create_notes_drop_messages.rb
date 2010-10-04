class CreateNotesDropMessages < ActiveRecord::Migration

  def self.up
    drop_table :messages
    create_table :notes do |t|
      t.column :receiver_id, :integer, :null => false
      t.column :sender_id, :integer, :null => false
      t.column :message, :text, :null => false
      t.column :created_at, :datetime, :null => false
    end
    add_index :notes, :receiver_id
    add_index :notes, :sender_id
  end

  def self.down
    drop_table :notes
    # messages is not used in the app, so just create a stub for rollback
    create_table :messages
  end

end