class RemoveGroupQuestionMatches < ActiveRecord::Migration

  def self.up
    drop_table :group_question_matches
  end

end