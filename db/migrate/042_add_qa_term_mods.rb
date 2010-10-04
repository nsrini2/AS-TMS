class AddQaTermMods < ActiveRecord::Migration

  def self.up
    add_column :questions, :add_terms, :text
    add_column :questions, :exclude_terms, :text
    add_column :answers, :add_terms, :text
    add_column :answers, :exclude_terms, :text
  end

  def self.down
    remove_column :questions, :add_terms
    remove_column :questions, :exclude_terms
    remove_column :answers, :add_terms
    remove_column :answers, :exclude_terms
  end

end
