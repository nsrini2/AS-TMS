class AddCompanyBlogNotificationToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :company_blog_notification, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :company_blog_notification
  end
end
