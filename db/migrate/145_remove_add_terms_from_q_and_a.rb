class RemoveAddTermsFromQAndA < ActiveRecord::Migration
  def self.up
    remove_column :questions, :add_terms
    remove_column :answers, :add_terms
  end

  def self.down
    add_column :questions, :add_terms, :text
    add_column :answers, :add_terms, :text
  end
end
