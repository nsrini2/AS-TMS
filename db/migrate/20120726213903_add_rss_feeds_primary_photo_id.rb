class AddRssFeedsPrimaryPhotoId < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :primary_photo_id, :integer
  end

  def self.down
    remove_column :rss_feeds, :primary_photo_id
  end
end
