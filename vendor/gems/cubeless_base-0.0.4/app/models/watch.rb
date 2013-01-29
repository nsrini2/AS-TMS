class Watch < ActiveRecord::Base

  belongs_to :watcher, :class_name => 'Profile'
  belongs_to :watchable, :polymorphic => true

  def watch_events(options={})
    ModelUtil.add_joins!(options,"join watches where watches.id=#{id} and watches.watchable_type=watch_events.watchable_type and watches.watchable_id=watch_events.watchable_id")
    WatchEvent.find(:all,options)
  end

  def validate
    errors.add_to_base("You cannot watch a private group you are not a member of") if watchable.is_a?(Group) && watchable.is_private? && !watchable.is_member?(watcher)
  end
end