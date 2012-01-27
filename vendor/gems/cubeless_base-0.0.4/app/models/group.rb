class Group < ActiveRecord::Base  
  acts_as_auditable :enabled => false # abuse will take snapshots only

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  has_many :notes, :order => 'notes.created_at DESC', :include => [:sender,:abuse], :as => :receiver

  has_many :group_memberships, :dependent => :destroy
  has_many :members, :through => :group_memberships
  has_many :moderators, :through => :group_memberships, :source => :member, :conditions => "moderator=1", :order => "screen_name"

  has_many :referred_questions, :class_name => 'QuestionReferral', :as => :owner, :dependent => :destroy

  has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['question_referrals.active = 1 and questions.open_until > ?', Date.today], :uniq  => true

  has_many :invitations, :class_name => 'GroupInvitation', :dependent => :destroy
  has_many :invitation_requests, :class_name => 'GroupInvitationRequest', :dependent => :destroy

  has_many :group_posts, :dependent => :destroy, :order => "group_posts.created_at desc"

  has_one :group_photo, :as => :owner, :dependent => :destroy

  has_many :visitors, :through => :visitations, :order => "visitations.updated_at desc"
  has_many :visitations, :as => :owner, :dependent => :destroy

  has_one :blog, :as => :owner, :dependent => :destroy

  has_one :group_announcement, :dependent => :destroy

  belongs_to :last_updater, :class_name => 'Profile', :foreign_key => 'last_updated_by'
  belongs_to :primary_photo, :class_name => 'GroupPhoto', :foreign_key => 'primary_photo_id'

  has_many :watch_events, :as => :watchable, :order => "created_at desc", :dependent => :delete_all

  belongs_to :owner, :class_name => 'Profile'

  belongs_to :sponsor_account

  has_many :gallery_photos

  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of [:name, :description, :tags]
  validates_length_of :name, :within => 1..100, :allow_blank => true
  validates_length_of :description, :within => 1..450, :allow_blank => true
  validates_length_of :tags, :within => 1..256, :allow_blank => true

  named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }

  def audit_snapshot!
    audit = super
    if primary_photo
      photo = primary_photo.thumbnails.find_by_thumbnail('thumb_large')
      # copy the large thumbnail for reference
      copy = photo.copy!(GenericAttachment)
      audit.add_reference(copy)
    end
  end

  # currently these used for activity stream - content updated
  @@content_fields = [:name,:description,:tags]
  def content_fields_changed?
    any_attributes_modified?(*@@content_fields)
  end

  def self.find(*args)
    here args
    
    current_profile = AuthenticatedSystem.current_profile
    #!H super-awful performance hack
    ModelUtil.add_selects!(args,"groups.*, (select count(1) from group_memberships where group_id=groups.id and profile_id=#{current_profile.id}) as current_profile_is_member, #{current_profile.id} as current_profile_id") if current_profile
    ModelUtil.add_includes!(args,:primary_photo)
    
    here args
    
    super(*args)
  end

  def self.find_by_full_name_and_type(name, type=[0,1,2], options={})
    Group.find(:all, (options).merge!({:order => 'name', :conditions => ["group_type in (?) and name like ?", type, "%#{name}%"]}))
  end

  def self.find_by_full_name(name, options={})
    Group.find(:all, (options).merge!({:order => 'name', :conditions => ["name like ?", "%#{name}%"]}))
  end

  def self.find_by_keywords(query, options)
    SemanticMatcher.default.search_groups(query, options.merge!({:direct_query => true}))
  end

  # def self.create(attributes, created_by_profile)
  #   group = Group.new attributes
  #   group.last_updated_by = created_by_profile.id
  #   group.owner = created_by_profile
  #   if group.save
  #     group.members << created_by_profile
  #     Watch.create(:watcher => created_by_profile, :watchable => group) unless created_by_profile.is_watching?(group)
  #   end
  #   group
  # end
  before_create :set_last_updated_by
  def set_last_updated_by
    self.last_updated_by ||= self.owner.id
  end
  after_create :add_owner_to_membership_and_watch_list
  def add_owner_to_membership_and_watch_list
    # self.members << self.owner
    GroupMembership.create(:group => self, :member => self.owner)
    Watch.create(:watcher => self.owner, :watchable => self) unless self.owner.is_watching?(self)
  end
  
  def full_name
    name
  end
  
  @@group_types = { 0 => 'Public', 1 => 'Invite Only', 2 => 'Private' }
  def type
    @@group_types[ group_type ]
  end

  def is_public?
    group_type == 0
  end

  def is_invite_only?
    group_type == 1
  end

  def is_private?
    group_type == 2
  end

  def is_sponsored?
    !!sponsor_account
  end

  def increment_group_views!
    ActiveRecord::Base.connection.update("update groups set views=views+1 where id=#{self.id}")
  end

  def is_member?(profile)
    return self[:current_profile_is_member].to_i>0 if self[:current_profile_id] && self[:current_profile_id].to_i==profile.id #!H super-awful performance hack
    #!O not a prob with the model, but pretty much any place that uses this needs optimization (env state cache)
    Group.count_by_sql("select count(1) from group_memberships where group_id=#{self.id} and profile_id=#{profile.id}")>0
  end

  def is_moderator?(profile)
    # return self[:current_profile_is_moderator].to_i>0 if self[:current_profile_id] && self[:current_profile_id].to_i==profile.id #!H super-awful performance hack
    ###
    self.moderators.include?(profile) #!O this sucks performance-wise
  end

  def is_owner?(profile)
    owner == profile
  end

  def editable_by?(profile)
    (self.moderators.count > 0 ? self.is_moderator?(profile) : self.is_member?(profile) ) || profile.has_role?(Role::ShadyAdmin) || self.is_owner?(profile)
  end

  def invitation_can_be_accepted_by?(profile)
    ((self.moderators.count > 0 ? self.is_moderator?(profile) : self.is_member?(profile) ) || self.is_owner?(profile))
  end

  def invitation_can_be_accepted_or_sent_by?(profile)
    !profile.has_role?(Role::SponsorMember) && ((self.moderators.count > 0 && !self.is_public? ? self.is_moderator?(profile) : self.is_member?(profile) ) || self.is_owner?(profile))
  end

  def is_private_and_members_include?(profile)
    is_private? && is_member?(profile)
  end

  def has_members?
    group_memberships_count > 0
  end

  def primary_photo_path(which=:thumb)
    primary_photo.public_filename(which) if !primary_photo.nil?
  end

  @@group_activity_status = {0 => "Low", 1 => "Medium", 2 => "High"}

  def stat_text
    @@group_activity_status[self.activity_status]
  end

  @@active_timeout_in_minutes = 30
  def active_users_count
    GroupMembership.count(:conditions => ["group_id = ? and last_accessed>timestampadd(minute,-#{@@active_timeout_in_minutes},now())", self.id], :include => :member)
  end

  def self.update_activity
    ActiveRecord::Base.connection.update("update groups g set activity_points =
    (select count(1) from group_memberships gm where gm.group_id = g.id and DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= created_at) +
    (select count(1) from group_posts gp where gp.group_id = g.id and DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= created_at) +
    (select count(1) from blog_posts bp, blogs b where b.id = bp.blog_id and b.owner_type = 'Group' and b.owner_id = g.id and DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= bp.created_at) +
    (select count(1) from comments c join blog_posts bp on bp.id = c.owner_id join blogs b on b.id = bp.blog_id where b.owner_type ='Group' and b.owner_id = g.id and DATE_SUB(CURDATE(),INTERVAL 7 DAY) <= c.created_at)")
    rs = ActiveRecord::Base.connection.select_all("select avg(activity_points) as avg, std(activity_points) as std from groups")
    std, avg = rs[0]['std'], rs[0]['avg']
    ActiveRecord::Base.connection.update("update groups g set activity_status = (case when ((g.activity_points - #{std.to_f}) / #{avg.to_f}) >= 1 then 2 when ((g.activity_points - #{std.to_f}) / #{avg.to_f}) >= 0 then 1 else 0 end)")
  end

  def make_unmoderated!
    GroupMembership.update_all("moderator=0","group_id=#{self.id}")
  end

  def make_owner_moderator!
    ActiveRecord::Base.connection.update("update group_memberships set moderator=case profile_id when #{self.owner_id} then 1 else 0 end where group_id=#{self.id}")
  end

  def transfer_ownership_to!(profile)
    Group.transaction do
      was_moderator = self.is_moderator?(owner)
      self.owner = Profile.find(profile)
      self.group_memberships.find_by_profile_id(owner.id).update_attributes(:moderator => true) if was_moderator
      self.save
    end
  end
  
  def stats
    stats = {}
    
    #group talk
    stats[:total_group_posts] = GroupPost.count(:all, :conditions => { :group_id => self.id }) || 0
    number_of_replies = Comment.count(:all, :joins => "inner join group_posts on group_posts.id = comments.owner_id and comments.owner_type = 'GroupPost'", :conditions => ["group_posts.group_id = ?", self.id])
    stats[:average_number_of_replies] = number_of_replies > 0 ? stats[:total_group_posts] / number_of_replies : 0    
    stats[:biggest_talker] = Profile.find_by_sql(["select * from group_posts gp,profiles p where gp.profile_id = p.id and gp.group_id = ? group by gp.profile_id order by count(1) DESC limit 1", self.id]).first || nil

    #blog posts
    stats[:total_blog_posts] = BlogPost.count(:all, :joins => :blog, :conditions => ["blogs.owner_id = ?", self.id]) || 0
    number_of_comments = Comment.count(:all, :joins => "inner join blogs on blogs.id = comments.owner_id and comments.owner_type = 'BlogPost'", :conditions => ["blogs.owner_id = ?", self.id])
    stats[:average_number_of_comments] = number_of_comments > 0 ? stats[:total_blog_posts] / number_of_comments : 0
    stats[:most_commented_on_blog_post] = BlogPost.find(:all, :include => :blog, :conditions => ["blogs.owner_id = ?", self.id], :limit => 1, :order => "blog_posts.comments_count DESC").first
    stats[:highest_rated_blog_post] = BlogPost.find(:all, :include => :blog, :conditions => ["blogs.owner_id = ?", self.id], :limit => 1, :order => "blog_posts.rating_avg DESC").first
    stats[:biggest_blogger] = Profile.find_by_sql(["select * from blog_posts bp, blogs b, profiles p where b.owner_id = ? and b.owner_type = 'Group' and bp.blog_id = b.id and bp.profile_id = p.id group by bp.profile_id order by count(1) DESC limit 1", self.id]).first || nil
    
    stats
  end
  
  def send_mass_mail(sender_id, subject, message, options={})
    sender = Profile.find(sender_id)
    recipients = options[:test_enabled] ? Array(sender.email) : members.collect(&:email)
      
    BatchMailer.group_mass_mail(self, sender, subject, message, recipients)
  end

  protected

  def before_save
    self.content_updated_at = Time.now if content_fields_changed?
  end

  def after_save
    SemanticMatcher.default.group_updated(self) if any_attributes_modified?(:name,:description,:tags)
  end

  def after_create
    self.create_blog
    profile = self.owner
    if profile.is_sponsored? && profile.groups.size==1
      profile.visible = 1
      profile.save!
    end
  end

  def after_destroy
    SemanticMatcher.default.group_deleted(self)
  end

end