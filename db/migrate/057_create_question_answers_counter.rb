class CreateQuestionAnswersCounter < ActiveRecord::Migration
  def self.up
    add_column :questions, :answers_count, :integer, :default => 0
    Question.recalculate_all_answer_counts!
    add_index :questions, :answers_count
  end

  def self.down
    remove_column :questions, :answers_count
  end
end
