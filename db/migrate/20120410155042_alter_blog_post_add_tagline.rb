class AlterBlogPostAddTagline < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :tagline, :text
  end

  def self.down
    remove_column :blog_posts, :tagline
  end
end
