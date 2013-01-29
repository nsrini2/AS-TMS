class AlterBlogPostsAddBestImage < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :best_image, :text
  end

  def self.down
    remove_column :blog_posts, :best_image
  end
end
