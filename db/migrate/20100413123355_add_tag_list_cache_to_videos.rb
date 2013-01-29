class AddTagListCacheToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :tag_list_cache, :text
  end

  def self.down
    remove_column :videos, :tag_list_cache
  end
end
