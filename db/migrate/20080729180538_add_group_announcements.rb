class AddGroupAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :group_announcements do |t|
      t.text :content
      t.integer :group_id
      t.datetime :start_date, :end_date
    end
    add_index :group_announcements, :group_id, :unique => true
  end

  def self.down
    drop_table :group_announcements
  end
end
