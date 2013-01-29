class WatchObserver < ActiveRecord::Observer

  observe Question, BlogPost, QuestionReferral, Note, GroupPost, Comment, GroupPhoto, Group, GroupMembership

  def after_create(model)
    case model
      when Question
        question = model
        # questions asked by people
        create_event(question,question.profile)
      when QuestionReferral
        referral = model
        # questions referred to a group
        return unless referral.owner_type=='Group'
        create_event(referral,referral,:owner)
      when BlogPost
        blog_post = model
        # blog posts on groups
        # blog posts by people
        create_event(blog_post,blog_post.blog,:owner)
      when GroupMembership
        group_membership = model
        create_event(group_membership,group_membership.group)
      when Note
        note = model
        # notes on groups
        if note.receiver.is_a?(Group)
          create_event(note,note,:receiver)
        end
      when GroupPost
        post = model
        create_event(post, post.group)
      when Comment
        comment = model
        # comments on group blog posts
        if comment.owner.is_a?(BlogPost)
          blog_post = comment.owner
          create_event(comment, blog_post.blog, :owner) if blog_post.root_parent.is_a?(Group)
        end
        if comment.owner.is_a?(GroupPost)
          pow_wow = comment.owner
          # comments on group pow wows
          create_event(comment, pow_wow.group)
        end
    end
  end
  
  @@monitor_save = [Group,GroupPhoto].to_set
  def after_save(model)
    return unless @@monitor_save.member?(model.class)
    case model
      when GroupPhoto
        WatchEvent.create(:watchable => model.owner, :action_item_type => model.class.to_s, :action_item_id => model.id, :profile_id => model.owner.last_updated_by) if model.parent_id.nil?
      when Group
        WatchEvent.create(:watchable_type => model.class.to_s, :watchable_id => model.id, :action_item => model, :profile_id => model.last_updated_by) if updated_awhile_ago?(model,'content_updated_at') #!R -- should add limitations to certain attributes modified?? (i.e. desc/name/tags)
    end
  end

  def after_destroy(model)
    WatchEvent.delete_all("action_item_type='#{model.class}' and action_item_id=#{model.id}")
  end

  @@public_profile_actions = [BlogPost,Question,QuestionReferral].to_set
  @@log_events_always = [Profile,Group].to_set

  # to avoid another nested lookup, watchable can be the parent of the watchable, followed by:
  # just poly_id, being the poly base name that poly_type and poly_id column names are based
  # or both poly_id (being the column name of the poly_id) and poly_class being the actual class
  def create_event(action_item,watchable,poly_id=nil,poly_class=nil)

    if poly_class
      poly_id = poly_id.to_s
      watchable_class = poly_class
      watchable_id = watchable[poly_id+'_id']
    elsif poly_id
      poly_id = poly_id.to_s
      watchable_class = Kernel.const_get(watchable[poly_id+'_type'])
      watchable_id = watchable[poly_id+'_id']
    else
      watchable_class = watchable.class
      watchable_id = watchable.id
    end

    private = event_is_private?(action_item) || (watchable_class==Profile && !@@public_profile_actions.member?(action_item.class))
    return if !@@log_events_always.member?(watchable_class) && Watch.exists?(:watchable_type => watchable.class.to_s, :watchable_id => watchable.id)
    
    WatchEvent.new { |event|
      event.watchable_type = watchable_class.to_s
      event.watchable_id = watchable_id
      event.action_item = action_item
      event.private = private
    }.save!
  end
  
  private
  
  def event_is_private?(model)
    case model
      when GroupPost
        return true
      when Comment
        return model.owner.is_a?(GroupPost)
      when Note
        return model.private?
    end
    false
  end

  def updated_awhile_ago?(modified,updated_at_field='updated_at',time_ago_seconds=900)
    return false unless modified.attribute_modified?(updated_at_field)
    orig_updated_at = modified.modified_attribute_loaded_value(updated_at_field)
    return orig_updated_at.nil? || (Time.now - orig_updated_at) > time_ago_seconds # 15 minutes
  end

end