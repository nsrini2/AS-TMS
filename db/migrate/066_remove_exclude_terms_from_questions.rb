class RemoveExcludeTermsFromQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :exclude_terms
  end

  def self.down
    add_column :questions, :exclude_terms, :text
  end
end