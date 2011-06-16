class UsersAddFavcebookGraph < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_graph, :text
  end

  def self.down
    remove_column :users, :facebook_graph
  end
end
