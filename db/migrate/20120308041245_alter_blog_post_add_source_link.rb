class AlterBlogPostAddSourceLink < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :source, :string
    add_column :blog_posts, :link, :string
    add_column :blog_posts, :guid, :string
  end

  def self.down
    remove_column :blog_posts, :source
    remove_column :blog_posts, :link
    remove_column :blog_posts, :guid
  end
end
