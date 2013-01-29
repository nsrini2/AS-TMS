class AddRatingsToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :rating_count, :integer, :null => false, :default => 0
    add_column :blog_posts, :rating_total, :integer, :null => false, :default => 0
    add_column :blog_posts, :rating_avg,   :decimal, :precision => 10, :scale => 2, :null => false, :default => 0
  end

  def self.down
    remove_column :blog_posts, :rating_count
    remove_column :blog_posts, :rating_total
    remove_column :blog_posts, :rating_avg
  end
end
