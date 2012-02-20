class AlterChatsAddPrimaryPhotoId < ActiveRecord::Migration
  def self.up
    add_column :chats, :primary_photo_id, :integer
  end

  def self.down
    drop_column :chats, :primary_photo_id    
  end
end
