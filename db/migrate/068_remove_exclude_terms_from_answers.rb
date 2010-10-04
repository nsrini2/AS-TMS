class RemoveExcludeTermsFromAnswers < ActiveRecord::Migration
  def self.up
    remove_column :answers, :exclude_terms
  end

  def self.down
    add_column :answers, :exclude_terms, :text
  end
end
