class WatchEvent < ActiveRecord::Base

  belongs_to :watchable, :polymorphic => true
  belongs_to :action_item, :polymorphic => true
  belongs_to :profile

  @@profile_events = [Question, BlogPost, QuestionReferral].map!{|x|x.name}

  def self.find(*args)
    ModelUtil.add_conditions!(args, ["watch_events.action_item_type in (?)", @@profile_events]) if ModelUtil.get_options!(args).delete(:following)
    self.preload_action_items!(super(*args))
  end

  #!O include hints, find a perm place later
  @@type_includes = { BlogPost => [{:profile => [:primary_photo]}], Question => [{:profile => [:primary_photo]}],
    QuestionReferral => [{:profile => [:primary_photo]}, :question, :owner]
  }
  
  def self.preload_action_items!(results)
    action_item_type_events = Hash.new { |hash,key| hash[key] = [] }
    results.each { |event| action_item_type_events[event.action_item_type] << event }
    action_item_type_events.each do |type,events|
      id_events = {}
      events.each { |event| id_events[event.action_item_id] = event }
      action_class = type.constantize # Kernel.const_get(type)
      find_options = { :conditions => "#{action_class.table_name}.id in (#{events.collect { |event| event.action_item_id }.join(',')})" }
      find_options[:include] = @@type_includes.fetch(action_class,[])
      action_class.find(:all, find_options).each do |action_item|
        id_events[action_item.id].action_item = action_item
      end
    end
    results
  end
  
  # groups
  @@group_events = [QuestionReferral, GroupPost, Comment, Note, BlogPost, GroupMembership]
  def self.find_for_group(gid, *args)
    ModelUtil.add_selects!(args,"watch_events.*, groups.*, questions.question as referral_text, group_posts.post as group_post_text" +
      ", comments.text as comment_text, blog_posts.title as blog_post_title")
      
    @@group_events.each {|ac| ModelUtil.add_joins!(args,"left join #{ac.table_name} on action_item_type='#{ac}' and #{ac.table_name}.id=action_item_id") }
    ModelUtil.add_joins!(args,"left join groups on groups.id=watchable_id")
    ModelUtil.add_joins!(args,"left join questions on questions.id=question_referrals.question_id")
    
    ModelUtil.add_conditions!(args,["watchable_type='Group' and watchable_id=?",gid])
    profile = Profile.last || AuthenticatedSystem.current_profile
    ModelUtil.add_conditions!(args,["watch_events.private=?",0]) unless GroupMembership.find_by_group_id_and_profile_id(gid, profile.id)
    
    options = ModelUtil.get_options!(args)
    options[:order] = 'watch_events.created_at desc' unless options.member?(:order)
    options[:limit] = 10 unless options.member?(:limit)
    
    find(:all, *args)
  end
  
  def self.delete_old_events!(max_keep)
    WatchEvent.connection.raw_connection.query(
    "select w1.watchable_type, w1.watchable_id, w1.id from watch_events w1 join watch_events w2 on w1.id<w2.id and w1.watchable_type=w2.watchable_type and w1.watchable_id=w2.watchable_id group by w1.id having count(1)=#{max_keep}"
    ).each { |rs|
      WatchEvent.delete_all(['watchable_type=? and watchable_id=? and id<=?',rs[0],rs[1].to_i,rs[2].to_i])  
    }
  end
  
end