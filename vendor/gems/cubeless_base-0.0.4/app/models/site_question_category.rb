class SiteQuestionCategory < ActiveRecord::Base
  include Config::Callbacks

  def has_questions?
    Question.find(:first, :conditions => ["category = ?", self.name])
  end

end
