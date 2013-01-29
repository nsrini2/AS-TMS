class AddVotesToBlogPost < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :num_positive_votes, :integer, :null => false, :default => 0
    add_column :blog_posts, :num_negative_votes, :integer, :null => false, :default => 0
    add_column :blog_posts, :net_helpful, :integer, :null => false, :default => 0

    add_index :blog_posts, :net_helpful
  end

  def self.down
    remove_column :blog_posts, :num_positive_votes
    remove_column :blog_posts, :num_negative_votes
    remove_column :blog_posts, :net_helpful
  end
end
