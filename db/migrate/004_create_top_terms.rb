class CreateTopTerms < ActiveRecord::Migration
  def self.up
    create_table :top_terms do |t|
      t.column :term, :string, :null => false
      t.column :rank, :integer, :null => false
    end
    add_index :top_terms, :term, :unique => true
    add_index :top_terms, :rank # for sorting
  end

  def self.down
    drop_table :top_terms
  end
end
