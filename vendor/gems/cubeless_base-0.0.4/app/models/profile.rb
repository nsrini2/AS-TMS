if File.exists?("#{Rails.root}/lib/assist/profile/registration.rb")
  require "#{Rails.root}/lib/assist/profile/registration"
elsif File.exists?("#{Rails.root}/vendor/plugins/cubeless/lib/assist/profile/registration.rb")
  require "#{Rails.root}/vendor/plugins/cubeless/lib/assist/profile/registration"
end

require 'cubeless_authorization'
require 'registration'
require 'karma'

class Profile < ActiveRecord::Base
  include CubelessAuthorization::RoleAccess
  
  acts_as_auditable :audit_unless_owner_attribute => :id

  xss_terminate :except => [:widget_config] # allow any html in widget code

  validates_presence_of [:first_name, :last_name, :user]
  attr_protected :keyterms_delimited, :karma_points, :roles

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'
  has_many :answers, :dependent => :destroy

  has_one :blog, :as => :owner
  has_many :blog_posts, :as => :creator

  has_many :bookmarks
    has_many :watched_questions, :through => :bookmarks,  :source => :question

  has_many :comments

  has_many :getthere_bookings do
    def current_and_upcoming
      find(:all, :conditions => ["getthere_bookings.end_time > ?", Time.now], :order => "getthere_bookings.start_time")
    end
  end

  has_many :group_memberships, :class_name => 'GroupMembership'
    has_many :groups, :through => :group_memberships

  has_many :group_posts
  has_many :notes, :order => 'notes.created_at DESC', :include => [:sender,:abuse], :as => :receiver
  has_many :sent_notes, :class_name => 'Note', :foreign_key => 'sender_id', :order => 'notes.created_at DESC', :include => [:receiver,:abuse]

  belongs_to :primary_photo, :class_name => 'ProfilePhoto', :foreign_key => :primary_photo_id
  has_many :profile_photos, :as => :owner

  has_many :profile_awards, :order => "profile_awards.created_at desc"
    has_many :awards, :through => :profile_awards, :order => "profile_awards.created_at desc" do
      def last
        find(:first, :conditions => "profile_awards.visible = true")
      end

      def default
        find(:first, :conditions => "profile_awards.is_default = true and profile_awards.visible = true")
      end

      def default_or_last
        default || last || find(:first)
      end
    end

  has_many :questions, :order => 'open_until ASC', :dependent => :destroy
  has_many :closed_questions, :class_name => 'Question',
  :conditions => 'open_until <= current_date()', :order => 'open_until ASC'
  has_many :open_questions, :class_name => 'Question',
  :conditions => 'open_until > current_date()', :order => 'open_until ASC'

  has_many :questions_referred, :class_name => 'QuestionReferral', :foreign_key => 'referer_id'
    has_many :questions_i_referred, :through => :questions_referred, :source => :question,
      :group => "questions.id"

  has_many :referred_questions, :class_name => 'QuestionReferral', :as => :owner
    has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
      :conditions => ['active = 1 and questions.open_until > ?', Date.today], :group => "questions.id"

  has_many :received_invitations, :class_name => 'GroupInvitation', :foreign_key => 'receiver_id'

  belongs_to :user, :dependent => :destroy

  has_many :visitations, :as => :owner, :dependent => :destroy
    has_many :visitors, :through => :visitations, :order => "visitations.updated_at desc" do
      def as_drive_bys
        find(:all, :limit => 48)
      end
    end
  has_many :visited, :class_name => 'Visitation', :dependent => :destroy

  has_many :watches, :foreign_key => 'watcher_id', :dependent => :delete_all
  
  belongs_to :sponsor_account
  
  has_registration_details # lib/assist/profile/registration
  
  has_many :statuses
  
  named_scope :exclude_profile, lambda { |profile| { :conditions => ["profiles.id != ?", profile.id] } }
  

  scope :visible, where(:visible => 1)
  scope :active, where(:status => 1)  
  scope :inactive, where("status < 1")  
  scope :status, lambda { |status| 
    case status.to_s
      when "visible": visible
      when "active": active
    end
  }


  def audit_snapshot!
    audit = super
    profile_photos.each do |photo|
      photo = photo.thumbnails.find_by_thumbnail('thumb_large')
      # copy the large thumbnail for reference
      copy = photo.copy!(GenericAttachment)
      audit.add_reference(copy)
    end
  end

  def pcc
    field = profile_registration_fields.find_by_site_registration_field_id(1)
    read_attribute(:pcc) || (field ? field.value : '')
  end

  def current_bookings
    getthere_bookings.find :all, :conditions => 'end_time > now()', :order => 'start_time asc'
  end

  # Watches/Favorites/Following
  def is_watching?(model)
    Watch.exists?(:watcher_id => id, :watchable_type => model.class.to_s, :watchable_id => model.id)
  end

  def watch_events(options={})
    ModelUtil.add_joins!(options,"join watches using (watchable_type, watchable_id)")
    ModelUtil.add_conditions!(options,["watcher_id=?", id])
    WatchEvent.find(:all,options.merge!(:following => true))
  end

  def questions_with_new_answers
    Question.find(:all,:select => 'questions.*, (select count(1) from answers where answers.question_id=questions.id) as num_answers',
    :joins => 'inner join answers on answers.question_id = questions.id',
    :conditions => ['answers.created_at > questions.author_viewed_at and questions.profile_id = ?', id],
    :group => :id)
  end

  def has_received_invitation?(group)
    GroupInvitation.exists?(:receiver_id => id, :group_id => group.id)
  end

  def has_requested_invitation?(group)
    GroupInvitationRequest.exists?(:sender_id => id, :group_id => group.id)
  end

  def joined(group)
    GroupMembership.find(:first, :conditions => ["profile_id = #{self.id} and group_id = #{group.id}"])
  end

  def self.all_visible_profiles(options={})
    self.visible
  end

  def self.random_visible_profiles(limit)
    # sql rand() is really expensive... so find the last N visible profiles and take the min of those N (i.e. the max_id, to ensure we get N records),
    # then retrieve N items from a random point from max_id and mix them up (sloppy rand sort)
    # i.e. you will always get a random sort of N adjacent profiles
    max_id = Profile.count_by_sql("select min(id) from (select p.id from profiles p join attachments a on a.id=p.primary_photo_id where visible=1 order by p.id desc limit #{limit}) x")
    Profile.visible.all(:joins => 'join attachments a on a.id=profiles.primary_photo_id', :conditions => ['profiles.id>=?',rand(max_id)+1], :limit => limit).to_a.sort! { |a,b| rand(3)-1 }
  end

  @@active_timeout_in_minutes = 30
  def self.active_users_count
    self.count_by_sql("select count(1) from profiles where last_accessed>timestampadd(minute,-#{@@active_timeout_in_minutes},now())")
  end

  def online_now?
    self.visible && self.last_accessed && self.last_accessed > Time.now-(@@active_timeout_in_minutes.minutes)
  end

  def is_sponsored?
    self && self.has_role?(Role::SponsorMember)
  end

  def sponsor?
    is_sponsored?
  end

  def has_global_group_email_preferences?
    if self.group_note_email_status &&
    self.group_blog_post_email_status &&
    self.group_post_email_status &&
    self.group_referral_email_status
      return true
    else 
      return false
    end
  end

  def turn_off_global_group_email_preferences!
    self.group_note_email_status = nil
    self.group_blog_post_email_status = nil
    self.group_post_email_status = nil
    self.group_referral_email_status = nil
    self.save
  end

  def turn_on_global_group_email_preferences!
    self.group_note_email_status = 1
    self.group_blog_post_email_status = 1
    self.group_post_email_status = 1
    self.group_referral_email_status = 1
    self.save
  end

  # Status States
  # 3 activate on login from easy registration
  # 2 activate on login
  # 1 active
  # 0 inactive
  # -1 delete (queued)
  # -2 deleted
  # -3 pending
  def status=(v)
    super(v) if(-3..3).include?(v.to_i)
  end

  @@status_names = {3 => 'activate on login from easy registration', 2 => 'activate on login', 1=> 'active', 0 => 'inactive', -1 => 'delete', -2 => 'deleted', -3 => 'pending'}
  def status_name
    @@status_names[status]
  end

  def activate_on_login?
    status == 2
  end

  def active?
    status == 1
  end
  
  def new_user?
    (active? || activate_on_login?) && last_login_date.blank? && ((user.uses_login_pass? && user.crypted_password.blank?) || !user.uses_login_pass?)
  end

  def self.find_by_smarts(query, options={})
    SemanticMatcher.default.search_profiles(query, options.merge!({:direct_query => true}))
  end

  def self.all_visible_profiles_by_full_name(query, options={})
    self.visible.find_by_full_name(query.downcase, options)
  end

  def num_group_slots_earned
    return self.group_slots_override unless self.group_slots_override.blank?
    case self.karma_points
      when 0..9 : 5
      when 10..19 : 10
      when 20..39 : 15
    else 20
    end
  end

  def num_group_slots_remaining
    num_group_slots_earned - groups.size
  end

  def self.get_questions_from_config
    # @@config_questions ||= profile_biz_card_questions.merge(profile_complex_questions)
    profile_biz_card_questions.merge(profile_complex_questions)
  end

  def self.get_question_list_containing_attr_value(questions, attr,value)
    questions.inject([]) { |list,(name,question)| list << name if question[attr] == value; list }
  end

  class << self
    alias_method :original_find, :find
  end
  def self.find(*args)
    ModelUtil.add_includes!(args,:user,:primary_photo)
    #ModelUtil.add_conditions!(args, ["status != ?", -2])
    
    # Detect the old hacky :status key and use the visible scope when appropriate
    opts = args[1]
    if opts && opts[:status] && opts[:status].to_sym == :visible
      args[1].delete(:status)
      s = visible
      s.find(*args)
    else
      super(*args)
    end
  end

  def self.answers_to_my_questions(profile_id, options={})
    Answer.find(:all, options.merge!({:joins => "join questions on answers.question_id = questions.id",
      :conditions => ["questions.profile_id = ?", profile_id],
      :order => "answers.created_at desc"}))
  end

  def primary_photo_path(which=:thumb)
    primary_photo.public_filename(which) if !primary_photo.nil? && visible?
  end

  def primary_photo_present?
    !primary_photo.nil? && visible?
  end

  def increment_profile_views!
    ActiveRecord::Base.connection.update("update profiles set profile_views=profile_views+1 where id=#{self.id}")
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def concat_with_delimeter(v1,v2,delim)
    return v2.to_s if v1.blank?
    return v1.to_s if v2.blank?
    "#{v1}#{delim}#{v2}"
  end

  def editable_by?(profile)
    profile and (profile == self or profile.has_role?(Role::ShadyAdmin))
  end

  def screen_name
    return 'a former member' if status < 0 && status != -3
    return 'Administrator' if self.has_role?(Role::CubelessAdmin, Role::ShadyAdmin) and !visible?
    super
  end

  def email
    user.email
  end

  def created_at
    user && user.created_at
  end

  def locked?
    user.locked?
  end

  def keyterms_delimited
    keyterms_set().to_a.join(',')
  end

  # this will return a Set of keyterms for the profile, less exclude terms
  def keyterms_set
    SemanticMatcher.default.get_profile_keyterms_set(self)
  end

  def exclude_terms_delimited
    self.exclude_terms
  end

  def exclude_terms_delimited=(words)
    words = '' if words.nil?
    #!I case handling, cleaning, duplicates, injection/protection, remove words not in master keyterms set, etc.
    words.downcase!
    # remove dups
    self.exclude_terms = Set.new(words.split(',')).to_a.join(',')
  end

  # this will return a Set of keyterms from the exclude_terms delimited list
  def exclude_terms_set
    Set.new(self.exclude_terms.nil? ? nil : self.exclude_terms.split(','))
  end

  def exclude_terms_set=(words_set)
    self.exclude_terms = words_set.to_a.join(',')
  end

  def matchable_text
    result = ''
    def format(text)
      text.nil? || text.length<1 ? '' : "#{text}. "
    end
    @@matchable_fields.each { |f| result << format(send(f)) }
    result
  end

  def matched_questions(options={})
    options[:summary] = true
    SemanticMatcher.default.get_profile_matched_questions(Question,self,options)
  end

  def self.extract_name_options_from_query(query)
    last,first = query.split(',',2)
    first,last = query.split(' ',2) unless first
    first = "#{first.strip}%" if first
    last = "#{last.strip}%" if last
    screen_name = "#{query.strip}%"
   	["((alt_first_name like ? or first_name like ?) #{last ? 'and' : 'or'} (alt_last_name like ? or last_name like ?) or screen_name like ?)",first,first,last||first,last||first,screen_name]
  end

  def self.find_by_full_name(name, options={})
    args = Profile.extract_name_options_from_query(name)
    Profile.find(:all, {:order => 'last_name, first_name'}.merge!(options).merge!(:conditions => args))
  end

  def self.find_by_full_name_login_or_screen_name(name, options={})
    name_query = Profile.extract_name_options_from_query(name)
    name_query[0] << " or users2.login like '#{name}%'"
    ModelUtil.add_joins!(options, "join users as users2 on users2.id = profiles.user_id")
    ModelUtil.add_conditions!(options, name_query)
    options[:order] ||= 'last_name, first_name'
    Profile.find(:all, options)
  end

  @@stats_query = 'select '+
  ' (select count(1) from question_referrals where referer_id=?) as questions_referred'+
  ', (select count(1) from answers where profile_id=?) as answers'+
  ', (select count(1) from answers a where a.best_answer=1 and a.profile_id=?) as best_answers'+
  ', (select profile_views from profiles where id=?) as profile_views'+
  ', (select count(1) from questions where profile_id=?) as questions'+
  ', (select count(1) from notes where receiver_id = ?)' + 
  ', (select count(1) from statuses where profile_id=?) as statuses'+    
  ' from dual'

  def stats
    #!H semantic matcher logic is copied here for matched_questions count. Have sm return sql logic at worst.
    obj = Hash.new(0)
    ps = ActiveRecord::Base.connection.raw_connection.prepare(@@stats_query)
    ps.execute(self.id, self.id, self.id,self.id,self.id,self.id,self.id)
    rs = ps.fetch
    obj[:questions_referred] = rs[0]
    obj[:answers] = rs[1]
    obj[:best_answers] = rs[2]
    obj[:profile_views] = rs[3]
    obj[:questions] = rs[4]
    obj[:notes] = rs[5]
    obj[:statuses] = rs[6]
    ps.close
    obj
  end

  def update_last_accessed!
    if self.last_accessed.nil? || self.last_accessed < Time.now-2.minutes
      # self.class.update_all("last_accessed=now()","id=#{id}")
      # reload
      self.update_attribute(:last_accessed, Time.now)
      self
    end
  end
  
  ##
  ## Naming conventions are legacy issues. 
  ## and trying to make the "REQUIRED TO COMPLETE PROFILE" Questions and biz card fields have 
  ##
  
  ##
  ## Further note if its a class method no need to put the class in the CLASS METHOD NAME
  ## Not now but sometime in the near future the profile_ should be removed from the CLASS methods
  ## below... ... ...
  ##
  def self.profile_biz_card_questions
    # @@profile_biz_card_questions ||= Proc.new {
    #       questions = Config[:profile_biz_card_questions]
    #       questions.inject({}) { |hash, question| hash[question['question']] = question; hash }
    #     }.call
    Proc.new {
      questions = Config[:profile_biz_card_questions]
      # questions.inject({}) { |hash, question| hash[question['question']] = question; hash }
      questions.inject({}) { |hash, question| hash.merge!({question['question'].to_s => question}) }
    }.call    
  end

  def self.profile_complex_questions
    # @@profile_complex_questions ||= Proc.new {
    #   questions = Config[:profile_complex_questions].inject([]){|questions, section| questions += section['questions']}
    #   questions.inject({}) { |hash, question| hash[question['question']] = question; hash }
    # }.call
    Proc.new {
      questions = Config[:profile_complex_questions].inject([]){|questions, section| questions += section['questions']}
      questions.inject({}) { |hash, question| hash.merge!({question['question'].to_s => question}) }
    }.call
  end
  
  def self.profile_complex_questions_total
    return profile_complex_questions.size
  end

  def self.profile_biz_card_fields_total
    return  profile_biz_card_questions.size
  end 
  
  def self.profile_complete_fields
     self.get_question_list_containing_attr_value(get_questions_from_config, 'completes_profile', true)
  end

  # MM2
  # Using these class causes big problems in iConfig.
  # We are trying to get rid of them
  @@profile_complete_fields = Profile.profile_complete_fields
  
  @@matchable_fields = self.get_question_list_containing_attr_value(get_questions_from_config, 'matchable', true)
  @@about_me_fields = self.get_questions_from_config.keys

  def question_field_required?(field_name)  # jes 
    Profile.profile_complete_fields.include? field_name.to_s  
  end 
    
  def all_fields_total
    return  Profile.profile_complete_fields.size
  end
  ##
  ## Naming conventions are legacy issues. 
  ## It would be best to move the profile fields and questions to a specfic table for such matters
  ## Currently the "Question" fields and "Profile" fields are for the profile bizcard and profile
  ## questions for the profile.  This is embedded into the PROFILES table
  def biz_cards_fields_profile_total
    cnt=0
    Profile.profile_biz_card_questions.each_pair do |k,v| 
      cnt += 1  if k.index('profile_')           
    end
    cnt
  end
  
  def complex_questions_profile_total
    cnt=0
    Profile.get_questions_from_config.each_pair do |k,v| 
      cnt += 1 if k.index('question_')
    end
    cnt
  end
  
  def biz_cards_fields_completes_profile_total
    cnt=0
    Profile.profile_biz_card_questions.each_pair do |k,v| 
       cnt += 1 if v["completes_profile"] &&  k.index('profile_')             
    end
    cnt
  end
  
  def complex_questions_completes_profile_total
    cnt=0
    Profile.get_questions_from_config.each_pair do |k,v| 
       cnt += 1 if v["completes_profile"] && k.index('question_')
    end
    cnt
  end
  
  def biz_card_fields_completed 
    cnt=0
    Profile.profile_biz_card_questions.each_pair do |k,v| 
      cnt += 1 if v["completes_profile"] && k.index('profile_') &&  
                  self.respond_to?(k) && !self.send(k).blank?           
    end
    cnt
  end

  def complex_questions_completed 
    cnt=0 
    Profile.get_questions_from_config.each_pair do |k,v| 
      cnt += 1 if v["completes_profile"] && k.index("question_") && 
                  self.respond_to?(k) && !self.send(k).blank?     
    end
    cnt
  end

  def biz_card_fields_incomplete
    return biz_cards_fields_completes_profile_total - biz_card_fields_completed 
  end

  def complex_questions_incomplete
    return complex_questions_completes_profile_total - complex_questions_completed 
  end

  def biz_card_complete?
    biz_card_fields_incomplete == 0 ? true : false        
  end

  def complex_questions_complete?
    complex_questions_incomplete == 0 ? true : false
  end
  
  def biz_card_labels(q)
     lbl=""
     return Profile.profile_biz_card_questions.each_pair do |k,v| 
       return lbl +=  v["label"] if v["completes_profile"] && k==q             
     end
  end
   
  def how_complete
     return (biz_card_fields_completed) if sponsor_account_id? 
     return biz_card_fields_completed + complex_questions_completed
  end
  
  def complete?
     tmp_profile_complete_fields =   self.class.get_question_list_containing_attr_value(self.class.get_questions_from_config, 'completes_profile', true) 
      tmp_profile_complete_fields.each { |sym| return false if self.send(sym).blank? }
      return false if self.profile_photos.size.zero?
      true
  end
  
  def completion_percentage
    return  biz_card_completion_percentage if sponsor_account_id?     
    (complex_question_completion_percentage.to_f + biz_card_completion_percentage.to_f)/2
  end

  def biz_card_completion_percentage
    return 100 if biz_card_fields_incomplete == 0 
    (biz_card_fields_completed.to_f/biz_cards_fields_completes_profile_total)  * 100   
  end

  def complex_question_completion_percentage
    return 100 if complex_questions_incomplete == 0
    (complex_questions_completed.to_f/complex_questions_completes_profile_total)   * 100 
  end

  #### KARMA ####
  def self.add_karma!(profile_id, points)
    profile = Profile.find(profile_id)
    profile.karma_points += points
    profile.save
  end

  def add_karma_for_login!
    unless self.last_login_date == Date.today
      self.last_login_date = Date.today
      self.karma_points += 1
      self.karma_login_points += 1
      save!
    end
  end

  #!R dont like this just yet, but it's a start
  def karma
    Karma.new(karma_points)
  end
  


  def enable_api!
      self.generate_api_key!
  end

  def disable_api!
    self.update_attribute(:api_key, nil)
  end

  def api_is_enabled?
    !self.api_key.nil?
  end

  protected

  def before_save
    self.about_me_updated_at = Time.now if any_attributes_modified?(*@@about_me_fields)
    self.visible = 0 if [-2,-1,2].include?(status.to_i)
  end

  def after_save
    SemanticMatcher.default.profile_updated(self) if any_attributes_modified?(*@@matchable_fields)
    # MysqlSemanticMatcher.new.profile_updated(self) if any_attributes_modified?(*@@matchable_fields)
  end

  def after_create
    self.create_blog
  end

  def after_destroy
    SemanticMatcher.default.profile_deleted(self)
    # ProfileTextIndex.delete_all(['profile_id=?',self.id])
    # QuestionProfileMatch.delete_all(['profile_id=?',self.id]) #!O destroy?
  end

  def self.profile_complete_fields
    # MM2: Class variable are bad for iConfig
    # @@profile_complete_fields
    get_question_list_containing_attr_value(get_questions_from_config, 'completes_profile', true)
  end

  def over_max_user_count?
    Config['user_max'] && 
    Config['user_max'].to_i != 0 && 
    Profile.count(:conditions => "status >= 0") > Config['user_max']
  end

  def is_new_or_status_changed?
    self.status >= 0 && (self.new_record? || (self.status_changed? && self.status_change[0] < 0))
  end

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def generate_api_key!
    self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
  end

  public

  def deactivate_permanently!

    @@profile_nil_data_fields ||= Profile.column_names - Profile.columns.select{ |c| !c.null }.collect{ |c| c.name } - ['screen_name']
    @@user_nil_data_fields ||= User.column_names - User.columns.select{ |c| !c.null }.collect{ |c| c.name }

    QuestionProfileMatch.destroy_all(['profile_id=?',id])
    GroupMembership.destroy_all(['profile_id=?',id])
    profile_photos.each { |photo| photo.destroy }

    self.destroy_notes!

    self.questions.update_all("per_answer_notification=0", ["profile_id=?",id]) #!H this should not be in here
    self.status = -2
    self.visible = false
    self.karma_points = 0
    self.screen_name = 'a former member'
    self.first_name = 'default_first'
    self.last_name = 'default_last'
    ModelUtil.nil_data!(self,@@profile_nil_data_fields)
    ModelUtil.nil_data!(user,@@user_nil_data_fields)

  end

  def destroy_notes!
    Note.destroy_all(["receiver_id=? and receiver_type='Profile'", self.id])
    Note.destroy_all(["sender_id=?",id])
  end

  def self.purge_data_if_deactivated!(days_inactive=45)
    Profile.find(:all,:conditions => ['status=? and profiles.updated_at<=?',-1,Date.today-days_inactive]).each do |p|
      puts "Deactivating profile #{p.id}..."
      p.deactivate_permanently!
    end
    nil
  end

  def validate
    sn = self[:screen_name]
    if attribute_modified?(:screen_name)
      # MM2: 
      # Apparently this validation only works on 'updates'
      # If the 'self.id' is NULL, this is NOT the correct way to compare with NULL. Use 'IS NOT NULL' instead
      # BUT.....
      # Before you change this, know that the Registration process for some Open Registration communities actually RELY ON THIS BUG
      # They don't allow 'screen name' as a field during registration and don't mind having duplicate screen names in the system.
      screen_name_taken = Profile.count_by_sql(['select count(1) from profiles where id<>? and screen_name=? limit 1',self.id,sn.downcase]) > 0
      errors.add :screen_name, "has already been taken." if screen_name_taken
    end
    if attribute_modified?(:karma_points)
      self.karma_points = Karma.karma_max if self.karma_points.to_i > Karma.karma_max
      self.karma_points = Karma.karma_min if self.karma_points.to_i <= Karma.karma_min
    end
    # errors.add :screen_name, ActiveRecord::Errors.default_error_messages[:blank] if sn.blank?
    errors.add :screen_name, "cannot be blank." if sn.blank?
    if is_new_or_status_changed? && over_max_user_count?
      errors.add :status, "^Exceeded maximum allowed number of users, please contact support at #{Config[:cubeless_support_email]}"
    end
  end
  
  def last_welcome_at
     self.last_sent_welcome_at
  end

end
