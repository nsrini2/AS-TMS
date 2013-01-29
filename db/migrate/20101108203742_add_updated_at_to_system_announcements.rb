class AddUpdatedAtToSystemAnnouncements < ActiveRecord::Migration
  def self.up
    add_column :system_announcements, :updated_at, :datetime
  end

  def self.down
    remove_column :system_announcements, :updated_at
  end
end
