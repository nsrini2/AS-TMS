class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :profile_id, :integer, :null => false
      t.column :sender_id, :integer, :null => false
      t.column :message, :text, :null => false
      t.column :created_at, :datetime, :null => false
    end
    add_index :messages, :profile_id
    add_index :messages, :sender_id
  end

  def self.down
    drop_table :messages
  end
end