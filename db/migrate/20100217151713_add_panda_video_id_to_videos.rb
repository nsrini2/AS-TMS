class AddPandaVideoIdToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :panda_video_id, :string
  end

  def self.down
    remove_column :videos, :panda_video_id
  end
end
