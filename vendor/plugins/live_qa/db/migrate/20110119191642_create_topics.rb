class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer :chat_id
      t.integer :owner_id
      t.string :title
      t.string :status
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
