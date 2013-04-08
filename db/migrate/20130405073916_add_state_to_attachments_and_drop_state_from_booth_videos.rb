class AddStateToAttachmentsAndDropStateFromBoothVideos < ActiveRecord::Migration
  def self.up
     remove_column :booth_videos, :state
     add_column :attachments, :state, :string
  end

  def self.down
     add_column :booth_videos, :state, :string
     remove_column :attachments, :state, :string
  end
end
