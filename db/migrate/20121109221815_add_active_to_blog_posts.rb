class AddActiveToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :active, :integer, :default => 1
  end

  def self.down
    remove_column :blog_posts, :active
  end
end
