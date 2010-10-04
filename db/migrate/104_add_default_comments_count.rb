class AddDefaultCommentsCount < ActiveRecord::Migration
  def self.up
    remove_column :blog_posts, :comments_count
    add_column :blog_posts, :comments_count, :integer, :null => false, :default => 0
  end

  def self.down
  end
end