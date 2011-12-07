class QuestionTextIndex < ActiveRecord::Base

  xss_terminate :except => self.column_names

  belongs_to :question

  def question_updated()
    self.question_text = self.question.question
    self.save!
  end

end
