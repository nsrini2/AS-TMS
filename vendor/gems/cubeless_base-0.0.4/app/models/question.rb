class Question < ActiveRecord::Base

  acts_as_auditable :audit_unless_owner_attribute => :profile_id

  belongs_to :profile
  has_many :answers, :order => "answers.created_at DESC", :dependent => :destroy

  has_many :referred_to_profiles, :source => :profile, :through => :referrals, :conditions => "question_referrals.owner_type = 'Profile'"
  has_many :referred_to_groups, :source => :group, :through => :referrals, :conditions => "question_referrals.owner_type = 'Group'"
  has_many :referred_by, :source => :referer, :through => :referrals
  has_many :new_answers, :class_name => 'Answer', :conditions => ["answers.created_at > questions.author_viewed_at"]

  has_many :referrals, :class_name => 'QuestionReferral', :dependent => :destroy

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  has_one :best_answer, :class_name => 'Answer', :conditions => 'best_answer=1'

  has_many :bookmarks, :dependent => :destroy
  has_many :watchers, :through => :bookmarks, :source => :profile

  # This validation was failing with categories that had spaces. It should not have.
  # Specs confirm that the way we are loading Config[:question_categories] from the db...
  # in conjunction with the built in validator is causing the problem.
  # Move to custom validation method fixes the issue.
  
  # validates_inclusion_of :category, :in => Config[:question_categories], :message => "can't be blank"
  validate :category_in_config
  def category_in_config
    unless Config[:question_categories].include?(self.category)
      errors.add_to_base("Category can't be blank.")
    end
  end
  
  
  validates_presence_of :question
  validates_presence_of :open_until

  validates_length_of :question, :within => 0...4000
  
  scope :summary, lambda { |*args| find_summary(*args) }
  scope :referral_owner, lambda{ |referral_owner|
    select("(select count(1) from question_referrals qr join profiles p_referer on qr.referer_id=p_referer.id where p_referer.status>0 and p_referer.visible=1 and questions.id=qr.question_id and qr.owner_id=#{referral_owner.id} and qr.owner_type='Profile') as num_referred_to_me, (select count(1) from question_referrals qr join profiles p_target on qr.referer_id=p_target.id where p_target.status>0 and p_target.visible=1 and questions.id=qr.question_id and qr.active = 1 and qr.referer_id=#{referral_owner.id}) as num_i_referred")  
  }

  self.per_page = 10
  
  def self.find(*args)
    # for use with collections (ie. profile.open_questions), otherwise use Question.find_summary
    return find_summary(*args) if ModelUtil.get_options!(args).delete(:summary)
    return auth_find(*args) if ModelUtil.get_options!(args).delete(:auth)
    super(*args)
  end

  def self.auth_find(*args)
    result = find(*args)
    ids = Array(result).collect{|x| x.id}.join(",")
    profile = AuthenticatedSystem.current_profile
    raise 'not authorized' if profile.is_sponsored? &&
      Question.count_by_sql("select count(1) from group_memberships gm join question_referrals qr on qr.question_id in (#{ids}) and qr.owner_type='Group' and qr.owner_id=gm.group_id where gm.profile_id=#{profile.id}")==0
    result
  end

  def self.open_questions(options={})
    ModelUtil.add_conditions!(options,'open_until>current_date()')
    find(:all,options)
  end

  def self.find_by_keywords(query, options={})
    options[:direct_query] = true
    SemanticMatcher.default.search_questions(Question, query, options)
  end

  def similar_questions(options={})
    ModelUtil.add_conditions!(options, ["questions.id!=?", self.id])
    options[:summary] = true
    SemanticMatcher.default.search_questions(Question, self.matchable_text, options)
  end

  def self.recalculate_all_answer_counts!
    update_all('answers_count=(select count(1) from answers where answers.question_id=questions.id)')
  end

  def new_answers_count
    ActiveRecord::Base.count_by_sql(['select count(0) from answers a, questions q where a.question_id = q.id and a.created_at > q.author_viewed_at and q.id=?', self.id])
  end

  def profiles_who_referred_to(profile_id, options={})
    ModelUtil.add_conditions!(options, ['question_referrals.owner_id = ? and question_referrals.owner_type = "Profile"', profile_id])
    self.referred_by.visible.find(:all, options)
  end

  def referred_to_profiles_by(profile_id, options={})
    ModelUtil.add_conditions!(options, ['referer_id = ?', profile_id])
    self.referred_to_profiles.find(:all, options)
  end

  def referred_to_groups_by(profile_id=nil, options={})
    ModelUtil.add_conditions!(options, ['referer_id = ?', profile_id]) if profile_id
    self.referred_to_groups.find(:all, options)
  end

  def is_open?
    self.open_until > Date.today
  end

  def is_closed?
    !self.is_open?
  end

  def close
    return if !self.is_open?
    self.open_until = Date.today
    self.save_with_validation(false)
  end

  def matchable_text
    question
  end

  def self.categories
    Config[:question_categories]
  end

  def update_author_viewed_at(profile)
    self.update_attributes(:author_viewed_at => Time.now) if self.authored_by?(profile)
  end

  ### Summary Methods ###

  def self.find_summary(*args)
    args.insert(0, :all) unless args.first == :all || args.first == :first || args.first == :last
    ModelUtil.get_options!(args).delete(:summary)
    ModelUtil.add_includes!(args,{:profile => [:user,:primary_photo]}, :abuse)
    ModelUtil.add_selects!(args,"questions.*, (select count(distinct qr.owner_id) from question_referrals qr where qr.question_id=questions.id and qr.owner_type='Group') as num_group_referrals")
    current_profile = AuthenticatedSystem.current_profile
    ModelUtil.add_selects!(args,"(select count(1) from bookmarks where question_id=questions.id and profile_id=#{current_profile.id} limit 1) as being_watched") if current_profile
    
    # referral_owner = ModelUtil.get_options!(args).delete(:referral_owner)
    # ModelUtil.add_selects!(args,"(select count(1) from question_referrals qr join profiles p_referer on qr.referer_id=p_referer.id where p_referer.status>0 and p_referer.visible=1 and questions.id=qr.question_id and qr.owner_id=#{referral_owner.id} and qr.owner_type='Profile') as num_referred_to_me, (select count(1) from question_referrals qr join profiles p_target on qr.referer_id=p_target.id where p_target.status>0 and p_target.visible=1 and questions.id=qr.question_id and qr.active = 1 and qr.referer_id=#{referral_owner.id}) as num_i_referred") if referral_owner
    
    find(*args)
  end

  def self.questions_answered(profile_id, options={})
    find_summary(:all, options.merge!(
    :joins => "join (select distinct question_id from answers where answers.profile_id=#{profile_id}) answered on answered.question_id=questions.id")) #!S sql injection?
  end

  def self.questions_answered_with_best_answers(profile_id, options={})
    find_summary(:all, options.merge!(
    :joins => "join (select distinct question_id from answers where answers.best_answer=1 and answers.profile_id=#{profile_id}) answered on answered.question_id=questions.id")) #!S sql injection?
  end

  def num_answers
    answers_count
  end

  def is_being_watched_by_current_user?
    self[:being_watched].to_i > 0
  end

  def num_referrals
    self[:num_referrals].to_i
  end

  def num_referred_to_me
    self[:num_referred_to_me].to_i
  end

  def num_i_referred
    self[:num_i_referred].to_i
  end

  def num_group_referrals
    self[:num_group_referrals].to_i
  end

  def match_rank
    self[:match_rank]
  end

  def referred_to?(owner)
    referred_to_group.count(:all,:conditions => "question_referrals.owner_id=#{owner.id}")>0
  end

  def sponsor_can_access?(sponsor)
    Question.count_by_sql("select count(1) from group_memberships gm join question_referrals qr on qr.question_id=#{self.id} and qr.owner_type='Group' and qr.owner_id=gm.group_id where gm.profile_id=#{sponsor.id}")>0
  end

  ### End Summary Methods ###

  def editable_by?(profile)
    (self.authored_by?(profile) && self.is_open?) || profile.has_role?(Role::ShadyAdmin)
  end

  protected

  def validate
    if self.new_record?
      errors.add(:open_until, "must be further out than today." ) if open_until.nil? || open_until <= Date.today
    end
  end

  def before_save
    self.open_until ||= (Date.today + 30)
  end

  def before_create
    self.profile = AuthenticatedSystem.current_profile
    self.author_viewed_at = Time.now
  end

  def after_save
    SemanticMatcher.default.question_updated(self)
  end

  def after_destroy
    SemanticMatcher.default.question_deleted(self)
  end

end
