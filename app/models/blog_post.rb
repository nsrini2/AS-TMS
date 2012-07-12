class BlogPost < ActiveRecord::Base
  include GroupOwned
  include Notifications::BlogPost
  stream_to :company
  after_save :update_indexes
  
  acts_as_taggable
  acts_as_auditable :audit_unless_owner_attribute => :profile_id
  acts_as_rated :rater_class => "Profile", :rating_range => 1..5
  validates_length_of :title, :within => 1..250, :too_short => "can't be blank"
  validates_length_of :text, :within => 1..65000 , :too_short => "^Post can't be blank", :too_long => "^Your Post has exceed the limit. Try multiple posts."
  validates_presence_of :tag_list, :message => "^Tags are required"
  validates_presence_of :blog
  validates_presence_of :profile

  xss_terminate  :except => [:text] 
 
  belongs_to :blog, :counter_cache => true
  belongs_to :profile

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  has_many :comments, :as => :owner, :order => "comments.created_at", :dependent => :destroy
  
  named_scope :recent, { :limit => 10 }
  
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  # SSJ -- REFACTOR THIS MAY BE EVIL, it can create invalid results if you are not unscoping this when requesting a different order
  default_scope order("blog_posts.created_at DESC")
  self.per_page = 5
  
  def group?
    self.blog.owner.class == Group
  end

  def company?
    self.blog.owner.class == Company
  end
  
  def news?
    self.blog.owner.class == News
  end
  
  def tagline
    return nil unless link
    read_attribute(:tagline).present? ? read_attribute(:tagline) : "View original content here."
  end

  def company_id
    if self.company?
      self.blog.owner_id
    end  
  end

  
  def get_company_recipients(members)
    subscriptions = members.select { |member| member.company_blog_notification && !self.authored_by?(member) }
    subscriptions.collect { |subscription| subscription.email }
  end
  
  def self.send_company_blog_post(id)
    blog_post = BlogPost.find(id)
    recipients = blog_post.get_company_recipients(blog_post.blog.owner.members)
    # BatchMailer.mail(blog_post, recipients) unless recipients.blank?
    tmail = Notifier.create_company_blog_post(blog_post)
    self.send_batch_email(tmail, recipients)
  end
  
  def self.find(*args)
    current_profile = AuthenticatedSystem.current_profile
    ModelUtil.add_joins!(args,"left join ratings on rated_type='BlogPost' and rated_id=blog_posts.id and rater_id=#{current_profile.id}") if current_profile
    ModelUtil.add_selects!(args,"ratings.rating as user_rating") if current_profile
    with_scope(:find => {:include => [:profile, :abuse, :blog ]}) do #!H to get around nested URL's doing nested lookups #!O cannot load owner, nested finds exceed limits (fails on group hub widget)
      super(*args)
    end
  end

  def root_parent
    blog.owner
  end

  def editable_by?(profile)
    return true if super(profile)
    self.root_parent.editable_by?(profile) if self.root_parent.is_a?(Group)
  end

  def deletable_by?(profile)
    return true if profile.has_role?(Role::ShadyAdmin)
    if self.root_parent.is_a?(Group)
      return self.root_parent.is_owner?(profile) || self.root_parent.is_moderator?(profile) 
    elsif self.root_parent.is_a?(Profile) || self.root_parent.is_a?(News)
      return self.profile == profile        
    end
    return false
  end

  def before_create
    self.created_at_year_month = Date.today.year*100 + Date.today.month
     
      # c = self.text
      #  self.text =  RedCloth.new(c).to_html 
   end


  def before_save 
      # c = self.text
      #  self.text =  RedCloth.new(c).to_html 
   end


  def user_has_rated
    user_rating > 0
  end

  def user_rating
    attributes['user_rating'].to_i
  end

  def self.find_by_keywords(query, options)
    SemanticMatcher.default.search_blog_posts(query, options.merge!({:direct_query => true}))
  end

  def increment_post_views!
    ActiveRecord::Base.connection.update("update blog_posts set views=views+1 where id=#{self.id}")
  end
  
  def self.send_group_blog_post(id)
    blog_post = BlogPost.find(id)
    recipients = blog_post.get_group_recipients(blog_post.blog.owner.group_memberships)
    # BatchMailer.mail(blog_post, recipients) unless recipients.blank?
    tmail = Notifier.create_group_blog_post(blog_post)
    self.send_batch_email(tmail, recipients)
  end
  
protected
  
  def update_indexes
    SemanticMatcher.default.blog_post_updated(self)
  end

end