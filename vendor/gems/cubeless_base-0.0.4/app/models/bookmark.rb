class Bookmark < ActiveRecord::Base
  belongs_to :profile
  belongs_to :question

  validates_uniqueness_of :question_id, :scope => [:profile_id]

  def self.destroy_by_question_and_profile(question_id, profile_id)
    find(:first, :conditions => ["question_id = ? and profile_id = ?", question_id, profile_id]).destroy
  end
end