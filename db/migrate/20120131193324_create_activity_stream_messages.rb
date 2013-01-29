class CreateActivityStreamMessages < ActiveRecord::Migration
  def self.up
    create_table :activity_stream_messages do |t|
      t.boolean :active, :default => true
      t.integer :primary_photo_id
      t.string :title
      t.string :description
      t.string :owner_link
      t.string :event_link

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_stream_messages
  end
end
