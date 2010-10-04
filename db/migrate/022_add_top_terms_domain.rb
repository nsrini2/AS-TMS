class AddTopTermsDomain < ActiveRecord::Migration
  def self.up
    add_column :top_terms, :domain, :string
    execute "update top_terms set domain='questions'"
    change_column :top_terms, :domain, :string, :null => false
    add_index :top_terms, [:domain,:rank]
    remove_index :top_terms, :term
  end
  def self.down
    execute "delete from top_terms where domain<>'questions'"
    remove_index :top_terms, [:domain,:rank]
    remove_column :top_terms, :domain
    add_index :top_terms, :term, :unique => true
  end
end