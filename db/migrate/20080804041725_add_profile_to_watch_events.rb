class AddProfileToWatchEvents < ActiveRecord::Migration
  def self.up
  	add_column :watch_events, :profile_id, :integer
  end

  def self.down
  	remove_column :watch_events, :profile_id
  end
end
