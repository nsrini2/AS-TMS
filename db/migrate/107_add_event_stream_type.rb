class AddEventStreamType < ActiveRecord::Migration

  def self.up
    add_column :activity_stream_events, :action, :string
    add_column :activity_stream_events, :group_id, :integer
    execute "update activity_stream_events set action='create' where klass='Answer'"
    execute "update activity_stream_events set action='create' where klass='Question'"
    execute "update activity_stream_events set action='update' where klass='Profile'"
    execute "update activity_stream_events set action='update' where klass='ProfilePhoto'"
    add_column :groups, :content_updated_at, :datetime
  end

  def self.down
    remove_column :groups, :content_updated_at
    remove_column :activity_stream_events, :action
    remove_column :activity_stream_events, :group_id
  end

end
