class AddViewsToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :views, :integer, :default => 0
  end

  def self.down
    remove_column :blog_posts, :views
  end
end
