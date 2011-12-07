class QuestionProfileMatch < ActiveRecord::Base

  belongs_to :profile
  belongs_to :question

  validate :ensure_company_scope
  
  def ensure_company_scope
    q = Question.unscoped.find_by_id(self.question_id)
    if q.company?
      self.errors[:base] << "only members of this compnay can view this question." unless profile.company == q.company      
    end
  end

  # Override getter method for question association
  def question_with_unscoped
    Question.unscoped { question_without_unscoped } if self.valid?
  end
  alias_method_chain :question, :unscoped
  
  def self.ignore(question_id, profile_id)
    QuestionProfileExcludeMatch.find_or_create_by_question_id_and_profile_id(self.question_id,self.profile_id)
    self.destroy
  end

  def after_destroy
    SemanticMatcher.default.question_profile_match_deleted(self)
  end
  


end
