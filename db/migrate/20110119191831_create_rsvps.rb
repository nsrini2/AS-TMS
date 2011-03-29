class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.integer :chat_id
      t.integer :profile_id
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :rsvps
  end
end
