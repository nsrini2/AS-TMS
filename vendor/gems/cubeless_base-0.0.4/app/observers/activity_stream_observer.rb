class ActivityStreamObserver < ActiveRecord::Observer

  observe Profile, ProfilePhoto, Group, GroupPhoto, BlogPost, Comment, GroupMembership, ProfileAward, Status

  @@monitor_create = [Group, BlogPost, GroupMembership, ProfileAward, Status].to_set
  def after_create(model)    
    return unless @@monitor_create.member?(model.class)
    return if skip_logging?(model)
    opts = {}
    case model
      when Group then opts[:group_id] = model.id
      when GroupPhoto then opts[:group_id] = model.owner_id
      when GroupMembership then opts.merge!(:profile_id => model.profile_id, :group_id => model.group_id)
      when ProfileAward then opts[:profile_id] = model.profile.id
      else opts[:profile_id] = model.profile_id
    end
    ActivityStreamEvent.add(model.class,model.id,:create,opts) unless opts.empty?
  end

  @@monitor_update = [Profile,Group].to_set
  def after_update(model)
    return unless @@monitor_update.member?(model.class)
    case model
      when Profile
        ActivityStreamEvent.add(Profile,model.id,:update,:profile_id => model.id) if model.visible and updated_awhile_ago?(model,'about_me_updated_at')
      when Group
        ActivityStreamEvent.add(model.class,model.id,:update,:group_id => model.id) if updated_awhile_ago?(model,'content_updated_at')
    end
  end

  @@monitor_save = [ProfilePhoto,GroupPhoto].to_set
  def after_save(model)
    return unless @@monitor_save.member?(model.class)
    case model
      when GroupPhoto
        ActivityStreamEvent.add(model.class,model.id,:update,:group_id => model.owner_id) if model.parent_id.nil? # only on primary photo
      when ProfilePhoto
        ActivityStreamEvent.add(model.class,model.id,:update,:profile_id => model.owner_id) if model.parent_id.nil? # only on primary photo
    end
  end

  def before_destroy(model)
    ## skip models that have been moved to concerns
    return if [Question, Answer].member?(model.class) 
    return ActivityStreamEvent.delete_all("profile_id=#{model.id}") if model.class==Profile
    return ActivityStreamEvent.delete_all("group_id=#{model.id}") if model.class==Group
    ActivityStreamEvent.delete_all("klass='#{model.class}' and klass_id=#{model.id}")
  end

  private

  def updated_awhile_ago?(modified,updated_at_field='updated_at',time_ago_seconds=900)
    return false unless modified.attribute_modified?(updated_at_field)
    orig_updated_at = modified.modified_attribute_loaded_value(updated_at_field)
    return orig_updated_at.nil? || (Time.now - orig_updated_at) > time_ago_seconds # 15 minutes
  end
  
  def skip_logging?(model)
    case model
      when BlogPost
        return model.blog.owner_type=='Group' && model.blog.owner.is_private? 
      when Comment
        return model.owner.is_a?(GroupPost) || (model.owner.is_a?(BlogPost) && model.owner.blog.owner.is_a?(Group) && model.owner.blog.owner.is_private?)
    end
    false
  end

end