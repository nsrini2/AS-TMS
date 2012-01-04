require 'ostruct'

class GroupEmailPreferences < OpenStruct
  def each_key(&block)
    for k,v in @table
      block.call(k,v)
    end
  end
  
  def to_h
    hash = {}
    self.each_key do | key, value |
      hash[key.to_s] = value
    end
    hash
  end
  
  def self.new_from_yaml(yaml)
    self.new( YAML::load(yaml || "") )
  end
  
  def to_s
    super
  end

end

class GroupMembership < ActiveRecord::Base
  include Notifications::GroupMembership
  acts_as_modified

  xss_terminate :except => [:email_preferences]

  belongs_to :member, :class_name => 'Profile', :foreign_key => 'profile_id'
  belongs_to :group, :counter_cache => true

  validates_presence_of [:member, :group]

  @email_preferences = nil
  def email_preferences
    @email_preferences ||= GroupEmailPreferences.new_from_yaml( email_preferences_yaml )
  end

  validate :group_membership_visibility_and_availability

  def group_membership_visibility_and_availability
    local_group = if self.group.is_a?(ActiveRecord::Relation)
                    begin
                      Group.find_by_id(self.group_id)
                    rescue
                      nil
                    end
                  else
                    group
                  end
    local_member =  if member.is_a?(ActiveRecord::Relation)
                      begin
                        Profile.find_by_id(self.member_id)
                      rescue
                        nil
                      end
                    else
                      member
                    end
    if new_record? && local_group && local_member
      if local_group.is_member?(local_member)
        errors.add_to_base("You are already a member of this group.")
      elsif !local_group.is_public? && local_group.has_members? && !member.has_received_invitation?(local_group)
        errors.add_to_base("You have not been invited to join this group.")
      elsif local_member.num_group_slots_remaining < 1
        errors.add_to_base("You have no open group spaces available.")
      end
    end
  end

  def self.update_last_visited!(group_id,profile_id)
    update_all("last_visited=now()","group_id=#{group_id} and profile_id=#{profile_id}")
  end
  
  def on
    created_at
  end

  @@email_prefs_hash = {
    :global => {
      :Note => 'group_note', 
      :BlogPost => 'group_blog_post', 
      :GroupPost => 'group_post', 
      :QuestionReferral => "group_referral"},
    :individual => {
      :Note => 'note', 
      :BlogPost => 'blog_post', 
      :GroupPost => 'group_talk_post', 
      :QuestionReferral => "question_referral"}
  }
  
  def wants_notification_for?(model)
    
    if self.member.has_global_group_email_preferences?
      eval("self.member.#{@@email_prefs_hash[:global][model.class.name.to_sym]}_email_status == 1")
    else
      
      eval("self.email_preferences.#{@@email_prefs_hash[:individual][model.class.name.to_sym]}")
    end
  
  end
  
  protected

  def before_create
    def self.is_true?(blah)
      blah == true || blah == 1 ? true : false
    end
    
    m = self.member
    self.email_preferences_yaml = YAML::dump({
      "note" => is_true?(m.group_note_email_status),
      "blog_post" => is_true?(m.group_blog_post_email_status),
      "group_talk_post" => is_true?(m.group_post_email_status),
      "referred_question" => is_true?(m.group_referral_email_status)
    })
  end

  def before_save
    self.email_preferences_yaml = YAML::dump( @email_preferences.to_h ) if @email_preferences
    Group.update_all("owner_id=#{self.profile_id}","id=#{self.group_id} and owner_id is null")
  end

  def after_create
    GroupInvitation.destroy_by_group_and_receiver(group_id, profile_id)
  end
  
  def after_destroy
    make_oldest_member_owner if owner_is_quitting?
  end
  
  def owner_is_quitting?
    self.group.owner_id == self.profile_id
  end

  def make_oldest_member_owner
    group = self.group
    has_members = group.members.count > 0
    oldest_member_id = group.group_memberships.find(:first, :order => 'created_at').profile_id if has_members
    Group.update_all("owner_id=#{has_members ? oldest_member_id : 'null'}", "id=#{self.group_id}")
    group.group_memberships.find_by_profile_id(oldest_member_id).update_attributes(:moderator => true) if has_members && group.moderators.count > 0
  end
  
end

