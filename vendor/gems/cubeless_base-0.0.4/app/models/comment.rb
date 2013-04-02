class Comment < ActiveRecord::Base

  acts_as_auditable :audit_unless_owner_attribute => :profile_id

  belongs_to :owner, :polymorphic => true, :counter_cache => true
  belongs_to :profile

  stream_to :activity

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  validates_length_of :text, :within => 1..4000, :too_long => "is too long. Limit to 4000 characters.", :too_short => "cannot be blank."

  default_scope :conditions => ["#{table_name}.active = 1"]
  
  def self.find(*args)
    with_scope(:find => {:include => [:profile, :abuse]}) do
      super(*args)
    end
  end
  
  def author
    self.profile
  end

  def author=(profile)
    self.profile=profile
  end
  
  def belongs_to_group_blog_post?
    self.owner                            &&
    self.owner.respond_to?(:root_parent)  &&
    self.owner.root_parent.is_a?(Group)   && 
    self.owner.is_a?(BlogPost)
  end

  def belongs_to_group_post?
    self.owner &&
    self.owner.is_a?(GroupPost)
  end
  
  def root_parent_profile?
    self.owner.respond_to?(:root_parent)   && 
    self.owner.root_parent                 &&
    self.owner.root_parent.is_a?(Profile)  
  end

end
