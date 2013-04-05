class BoothMarketingMessage < ActiveRecord::Base
has_one :marketing_image, :as => :owner, :dependent => :destroy
belongs_to :group
validates_presence_of :group_id

  def toggle_activation
    if last_message?
      self.errors.add_to_base="You must have at least one active booth marketing message."
    else
      self.toggle!(:active)
    end
  end

  def self.random_active_message(group_id)
    self.active_messages(group_id).sample
  end

  def self.active_messages(group_id)
    BoothMarketingMessage.find(:all, :conditions => ["active = ? and group_id =?", true, group_id] )
  end

  def editable_by?(group,profile)
    profile.has_role?(Role::ContentAdmin) || group.editable_by?(profile)
  end
end
