class GroupPost < ActiveRecord::Base
  include GroupOwned

  acts_as_auditable :audit_unless_owner_attribute => :profile_id
  
  validates_presence_of [:post, :group, :profile]
  validates_length_of :post, :within => 0..256, :allow_nil => true

  belongs_to :group
  belongs_to :profile

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  has_many :comments, :as => :owner, :order => "comments.created_at asc", :dependent => :destroy

  def send_group_post
    recipients = get_group_recipients(self.group.group_memberships)
    BatchMailer.mail(self, recipients) unless recipients.blank?
  end

end