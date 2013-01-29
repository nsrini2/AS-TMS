class ConvertOwnerTypeOfPostToNewsPost < ActiveRecord::Migration
  def self.up
    execute "update abuses set abuseable_type = 'NewsPost' where abuseable_type = 'Post'"
    execute "update comments set owner_type = 'NewsPost' where owner_type = 'Post'"
    execute "update votes set owner_type = 'NewsPost' where owner_type = 'Post'"
    execute "update watch_events set action_item_type = 'NewsPost' where action_item_type = 'Post'"
    execute "update activity_stream_events set klass = 'NewsPost' where klass = 'Post'"
    execute "update audits set auditable_type = 'NewsPost' where auditable_type = 'Post'"
  end

  def self.down
    execute "update abuses set abuseable_type = 'Post' where abuseable_type = 'NewsPost'"
    execute "update comments set owner_type = 'Post' where owner_type = 'NewsPost'"
    execute "update votes set owner_type = 'Post' where owner_type = 'NewsPost'"
    execute "update watch_events set action_item_type = 'Post' where action_item_type = 'NewsPost'"
    execute "update activity_stream_events set klass = 'Post' where klass = 'NewsPost'"
    execute "update audits set auditable_type = 'Post' where auditable_type = 'NewsPost'"
  end
end
