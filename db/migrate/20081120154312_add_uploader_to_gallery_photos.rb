class AddUploaderToGalleryPhotos < ActiveRecord::Migration
  def self.up
    add_column :gallery_photos, :uploader_id, :integer
  end

  def self.down
    remove_column :gallery_photos, :uploader_id
  end
end
