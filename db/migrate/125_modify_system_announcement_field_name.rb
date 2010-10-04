class ModifySystemAnnouncementFieldName < ActiveRecord::Migration
  def self.up
    rename_column :system_announcements, :text, :content
  end

  def self.down
    rename_column :system_announcements, :content, :text
  end
end
