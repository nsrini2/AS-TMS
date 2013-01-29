class CreateActivityStreamEvents < ActiveRecord::Migration

  def self.up
    create_table :activity_stream_events do |t|
      t.column :created_at, :datetime, :null => false
      t.column :klass, :string
      t.column :klass_id, :integer
      t.column :profile_id, :integer
    end
    add_index :activity_stream_events, :created_at
  end

  def self.down
    drop_table :activity_stream_events
  end
end
