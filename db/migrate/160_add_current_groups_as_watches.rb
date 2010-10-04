class AddCurrentGroupsAsWatches < ActiveRecord::Migration
  def self.up
    execute "insert into watches (watchable_id,watcher_id,watchable_type,created_at)
              select distinct gm.group_id,gm.profile_id,'Group',now() from group_memberships gm
              left join watches w on w.watcher_id=gm.profile_id and w.watchable_id=gm.group_id and w.watchable_type='Group'
              where w.watcher_id is null"
  end

  def self.down
  end
end
