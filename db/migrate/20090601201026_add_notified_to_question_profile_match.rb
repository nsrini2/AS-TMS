class AddNotifiedToQuestionProfileMatch < ActiveRecord::Migration
  def self.up
    add_column :question_profile_matches, :notified, :boolean, :default => false
    QuestionProfileMatch.update_all(:notified => true)
  end

  def self.down
    remove_column :question_profile_matches, :notified
  end
end
