require_cubeless_engine_file :model, :watch_event

class WatchEvent
  
  # MM2: Most of these are to allow a watched event to be displayed just like an activity stream event
  def primary_photo_path(which = :thumb)
    self.watchable ? self.watchable.primary_photo_path(which) : nil.to_s
  end

  def klass
    self.watchable.class.to_s
  end
  def action
    "update"
  end
  def group_id
    self.watchable.is_a?(Group) ? self.watchable.id : nil
  end
  def group_name
    self.watchable.is_a?(Group) ? self.watchable.name : nil
  end
  def profile_id
    self.watchable.is_a?(Profile) ? self.watchable.id : nil
  end
  
end