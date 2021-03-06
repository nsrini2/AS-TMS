require 'image_size'

class BlogPost < ActiveRecord::Base
  include SoftDelete
  include GroupOwned
  include Notifications::BlogPost
  include Rails.application.routes.url_helpers
  include ActionView::Context
  include Indexed::Add
  
  stream_to :company, :activity
 
  after_save :update_indexes
  
  acts_as_taggable
  acts_as_auditable :audit_unless_owner_attribute => :creator_id
  acts_as_rated :rater_class => "Profile", :rating_range => 1..5
  validates_length_of :title, :within => 1..250, :too_short => "can't be blank"
  validates_length_of :text, :within => 1..65000 , :too_short => "^Post can't be blank", :too_long => "^Your Post has exceed the limit. Try multiple posts."
  validates_presence_of :tag_list, :message => "^Tags are required"
  validates_presence_of :blog
  validates_presence_of :creator

  xss_terminate  :except => [:text] 
 
  belongs_to :blog, :counter_cache => true
  belongs_to :creator, :polymorphic => true

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  has_many :comments, :as => :owner, :order => "comments.created_at", :dependent => :destroy
  has_many :votes, :as => :owner, :dependent => :delete_all
  
  scope :recent, { :limit => 10 }
  default_scope :conditions => "#{table_name}.active > 0"
  
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  # SSJ -- REFACTOR THIS MAY BE EVIL, it can create invalid results if you are not unscoping this when requesting a different order
  # default_scope order("blog_posts.created_at DESC")
  self.per_page = 5
  
  def comments_text
    comments.map { |comment| comment.text }
  end
  
  def tags_text
    tags.map {|tag| tag.name }
  end
  
  def self.publicized
    BlogPost.joins(:blog).
      joins("INNER JOIN groups ON blogs.owner_id = groups.id").
      where("blogs.owner_type = 'Group'").
      where("groups.group_type <> 2").
      order("created_at DESC")
  end
  
  def link?
    read_attribute :link
  end
  
  def link
    if link?
      read_attribute :link
    else
      Rails.application.routes.url_helpers.blog_post_path(self)
    end
  end
  
  def image
    if link?
      self.best_image ||= calculate_best_image
      save! unless self.best_image_was == self.best_image
      if self.best_image
        self.best_image
      elsif news?
        creator.primary_photo_path(:thumb_large)
      else
        ""
      end
    else
      ""
    end
  end

  #SSJ 7/12 Needed profile interface stuff for old code to work with new polymorphic creator
  def profile_id
    case creator_type
    when "Profile"
      creator_id
    when "RssFeed"
      creator.profile.id
    end    
  end
  
  def profile
    case creator_type
    when "Profile"
      creator
    when "RssFeed"
      creator.profile
    end  
  end
  
  def profile=(profile)
    self.creator = profile
  end
  
  def group?
    self.blog.owner.class == Group
  end
  
  def private?
    company? || ( group? && self.blog.owner.private? )
    rescue Exception => e
      puts e.inspect
      true
  end

  def company?
    self.blog.owner.class == Company
  end
  
  def rss?
    creator_type == "RssFeed"
  end
  
  def news?
    self.blog.owner.class == News
  end
  
  def tagline
    return nil unless link?
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
  
  def self.send_news_blog_post(id)
    blog_post = BlogPost.find(id)
    recipients = NewsFollower.profiles.map { |follower| follower.email }
    tmail = Notifier.create_news_blog_post(blog_post)
    self.send_batch_email(tmail, recipients)
  end
  
  def self.by_rank
    # SSJ 2012-08-21 just create a custom order to bring most relavant data to the top
    reorder("((net_helpful *3) + (comments_count) + (views * 0.1)) - ((TO_DAYS(CURDATE()) - TO_DAYS(created_at)) * 0.5 ) DESC")
  end
  
  def self.find(*args)
    current_profile = AuthenticatedSystem.current_profile
    ModelUtil.add_joins!(args,"left join ratings on rated_type='BlogPost' and rated_id=blog_posts.id and rater_id=#{current_profile.id}") if current_profile
    ModelUtil.add_selects!(args,"ratings.rating as user_rating") if current_profile
    with_scope(:find => {:include => [:abuse, :blog ]}) do #!H to get around nested URL's doing nested lookups #!O cannot load owner, nested finds exceed limits (fails on group hub widget)
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
  
  def calculate_best_image
    image_selector = BestImage::ImageSelector.new(link)
    Rails.logger.info("Error getting best image -- #{image_selector.errors}") unless image_selector.errors.empty?
    image_selector.best_image
  end
end
