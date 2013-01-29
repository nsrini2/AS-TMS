class AddWatches < ActiveRecord::Migration

  def self.up
    create_table :watch_events do |t|
      t.datetime :created_at, :null => false
      t.string :watchable_type, :null => false
      t.integer :watchable_id, :null => false
      t.string :action_item_type, :null => false
      t.integer :action_item_id, :null => false
      t.boolean :private, :null => false, :default => false
      t.string :action
    end
    add_index :watch_events, [:watchable_type,:watchable_id,:private], :name => 'index_watch_events_on_watchable_and_private'

    create_table :watches do |t|
      t.datetime :created_at, :null => false
      t.integer :watcher_id, :null => false
      t.string :watchable_type, :null => false
      t.integer :watchable_id, :null => false
    end
    add_index :watches, [:watcher_id,:watchable_type,:watchable_id], :unique => true
    add_index :watches, [:watchable_type,:watchable_id]

  end

  def self.down
    drop_table :watches
    drop_table :watch_events
  end

end
