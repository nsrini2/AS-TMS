class AddCommentsCountToGalleryPhoto < ActiveRecord::Migration
  def self.up
    add_column :gallery_photos, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :gallery_photos, :comments_count
  end
end
