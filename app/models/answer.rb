require_cubeless_engine_file :model, :answer

class Answer < ActiveRecord::Base
  include Notifications::Answer
  stream_to :company, :activity
  
  def company?
    self.question.company?
  end
  
  def company_id
    self.question.company_id
  end
  
  def private?
    false
  end
  
  def question
    # SSJ because the url has the Question id, not the anser id
    # we should be able to access the Question anytime we can get the answer
    unscoped_question
  end
  
  def unscoped_question
    Question.unscoped.find(self.question_id)
  end

  def editable_by?(profile)
    (self.authored_by?(profile) && self.unscoped_question.is_open?) || profile.has_role?(Role::ShadyAdmin)
  end

end
