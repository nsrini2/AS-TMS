class AddStartAndEndDatesToSystemAnnouncements < ActiveRecord::Migration
  def self.up
    add_column :system_announcements, :start_date, :datetime
    add_column :system_announcements, :end_date, :datetime
  end

  def self.down
    remove_column :system_announcements, :start_date
    remove_column :system_announcements, :end_date
  end
end
