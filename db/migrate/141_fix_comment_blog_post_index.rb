class FixCommentBlogPostIndex < ActiveRecord::Migration

  def self.up
    remove_index :comments, :name => 'index_comments_on_blog_post_id'
  end

  def self.down
    raise 'cant go back'
  end

end
