class BestAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :best_answer, :boolean, :default => 0
    add_index :answers, :best_answer
  end

  def self.down
    remove_column :answers, :best_answer
  end
end
