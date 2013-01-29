class RemoveRepliesAndCommentsFromWatches < ActiveRecord::Migration
  def self.up
    execute "delete from watch_events where action_item_type in ('Comment','Reply')"
  end

  def self.down
  end
end
