class Answer < ActiveRecord::Base

  acts_as_auditable :audit_unless_owner_attribute => :profile_id

  belongs_to :question, :counter_cache => true
  belongs_to :profile

  has_many :votes, :as => :owner, :dependent => :delete_all

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'
  has_one :reply, :dependent => :destroy

  validates_presence_of :answer
  validates_length_of :answer, :within => 0...4000
  
  scope :summary, lambda { |*args| find_summary(*args) }

  def audit?
    # best answer is marked by the question author, we don't need an audit snapshot
    return false if self.best_answer and attribute_modified?(:best_answer)
    super
  end

  def self.find(*args)
    return find_summary(*args) if ModelUtil.get_options!(args).delete(:summary)
    ModelUtil.add_includes!(args,:reply)
    super(*args)
  end

  def matchable_text
    "#{answer} #{question.matchable_text}"
  end

  def editable_by?(profile)
    (self.authored_by?(profile) && self.question.is_open?) || profile.has_role?(Role::ShadyAdmin)
  end

  ### Summary Methods ###

  def self.find_summary(*args)
    # 2012-05-22 SSJ I would like to redo all of these find summary methods, but not ready to pull trigger -- using where, where needed
    # need to determine a good way to find all methods that call this find_summary as most are done with a generic model.find_summary
    args.insert(0, :all) unless args.first == :all
    ModelUtil.get_options!(args).delete(:summary)
    ModelUtil.get_options!(args).delete(:page)
    ModelUtil.add_includes!(args,{:profile => [:user,:primary_photo]}, :abuse)
    current_profile = AuthenticatedSystem.current_profile
    ModelUtil.add_selects!(args,"answers.*, (select count(1) from votes where votes.owner_id=answers.id and votes.profile_id=#{current_profile.id} and votes.owner_type='Answer' and votes.vote_value=true) as current_user_voted_positive, (select count(1) from votes where votes.owner_id=answers.id and votes.profile_id=#{current_profile.id} and votes.owner_type='Answer' and votes.vote_value=false) as current_user_voted_negative") if current_profile
    find(*args)
  end

  def current_user_voted_positive
    current_profile = AuthenticatedSystem.current_profile
    # attributes['current_user_voted_positive'].to_i > 0
    self.votes.where(:profile_id => current_profile.id).where(:vote_value => true).count > 0
  end

  def current_user_voted_negative
    current_profile = AuthenticatedSystem.current_profile
    # attributes['current_user_voted_negative'].to_i > 0
     self.votes.where(:profile_id => current_profile.id).where(:vote_value => false).count > 0
  end

  def current_user_has_voted?
    current_user_voted_positive || current_user_voted_negative
  end
    
  ### Utility Methods
  def mark_best_answer
     Answer.update_all( "best_answer = 0", "question_id = #{question.id} and best_answer = 1")
     self.best_answer = 1
     self.save 
  end  

  def is_best_answer_selected? 
    self.best_answer
  end 
  
  alias :is_best? :is_best_answer_selected?
  
  ### End Summary Methods ###

  protected

  def after_save
    SemanticMatcher.default.answer_updated(self) if attribute_modified?(:answer)
  end

  def after_create
    QuestionReferral.clear_all_by_question_id_and_owner(question_id, self.profile)
  end

  def after_destroy
    SemanticMatcher.default.answer_deleted(self)
  end


end
