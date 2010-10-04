class UpdateGroupPostWatchesToPrivate < ActiveRecord::Migration
  def self.up
  	execute "update watch_events set private=1 where action_item_type='GroupPost'"
  	execute "update watch_events join comments on watch_events.action_item_id=comments.id and comments.owner_type='GroupPost' set private=1 where action_item_type='Comment'"
  	execute "update watch_events join notes on watch_events.action_item_id=notes.id set watch_events.private=1 where notes.private=1"
  end

  def self.down
  end
end
