class AddTagsToGalleryPhoto < ActiveRecord::Migration
  def self.up
    add_column :gallery_photos, :cached_tag_list, :string
    add_index :gallery_photos, :cached_tag_list
  end

  def self.down
    remove_column :gallery_photos, :cached_tag_list
    remove_index :gallery_photos, :cached_tag_list
  end
end
