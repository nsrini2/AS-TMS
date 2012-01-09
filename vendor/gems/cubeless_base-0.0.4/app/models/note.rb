class Note < ActiveRecord::Base
  include GroupOwned
  include Notifications::Note

  acts_as_auditable :audit_unless_owner_attribute => :receiver_id, :exclude_events => [:create]

  belongs_to :sender, :class_name => 'Profile', :foreign_key => 'sender_id'
  belongs_to :receiver, :polymorphic => true
  named_scope :allow_group_member_or_sender_or_admin_to_see_all_for_receiver, lambda{|profile,receiver| (receiver.is_member?(profile) or profile.has_role?(Role::ShadyAdmin)) ? {} : {:conditions => ["private = 0 or sender_id = ?", profile.id]}}
  named_scope :allow_profile_or_admin_to_see_all_for_receiver, lambda{|profile,receiver| (receiver == profile or profile.has_role?(Role::ShadyAdmin)) ? {} : {:conditions => ["private = 0 or sender_id = ?", profile.id]}}
  named_scope :recent, { :limit => 10 }


  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  def authored_by?(profile)
    profile && (self.sender == profile)
  end
  
  def received_by?(profile)
    profile && (self.receiver == profile)
  end
  
  def send_group_note
    recipients = get_group_recipients(self.receiver.group_memberships)
    BatchMailer.mail(self, recipients) unless recipients.blank?
  end
end