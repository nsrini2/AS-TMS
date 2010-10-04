class AddNewCommentOnBlogNotificationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :new_comment_on_blog_notification, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :new_comment_on_blog_notification
  end
end
