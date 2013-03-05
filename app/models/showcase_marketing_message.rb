class ShowcaseMarketingMessage < ActiveRecord::Base
has_one :marketing_image, :as => :owner, :dependent => :destroy

  def toggle_activation
    if last_message?
      self.errors.add_to_base "You must have at least one active travel expo marketing message."
    else
      self.toggle!(:active)
    end
  end

  def self.random_active_message
    self.active_messages.sample
  end

  def self.active_messages
    ShowcaseMarketingMessage.find(:all, :conditions => ['active = ?', true])
  end

  def validate_on_destroy
    self.errors.add_to_base("You cannot delete the last active travel expo marketing message.") if self.last_message?
  end

  def last_message?
    count = ShowcaseMarketingMessage.count_by_sql "select count(1) from marketing_messages where active=1"
    count == 1 && self.active
  end
  
  def editable_by?(profile)
    profile.has_role?(Role::SponsorAdmin)
  end
end
