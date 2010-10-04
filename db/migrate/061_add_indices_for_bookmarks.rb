class AddIndicesForBookmarks < ActiveRecord::Migration
  def self.up
    add_index :bookmarks, :profile_id

  end

  def self.down
    remove_index :bookmarks, :profile_id
  end
end
