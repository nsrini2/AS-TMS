class AddFollowingProfileBlogNotificationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :following_profile_blog_notification, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :following_profile_blog_notification
  end
end
