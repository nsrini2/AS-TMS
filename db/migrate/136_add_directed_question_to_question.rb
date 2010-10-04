class AddDirectedQuestionToQuestion < ActiveRecord::Migration

  def self.up
    add_column :questions, :directed_question, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :questions, :directed_question
  end

end