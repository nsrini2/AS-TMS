class CreateSystemAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :system_announcements do |t|
      t.column "text", :text
    end
  end

  def self.down
    drop_table :system_announcements
  end
end