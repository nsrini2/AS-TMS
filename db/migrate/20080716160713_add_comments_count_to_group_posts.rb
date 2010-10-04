class AddCommentsCountToGroupPosts < ActiveRecord::Migration
  def self.up
    add_column(:group_posts, :comments_count, :integer, :limit => 11, :default => 0, :null => false)
  end

  def self.down
    remove_column(:group_posts, :comments_count)
  end
end
