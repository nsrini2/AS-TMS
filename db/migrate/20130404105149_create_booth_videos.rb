class CreateBoothVideos < ActiveRecord::Migration
  def self.up
    create_table :booth_videos do |t|
      t.string :title
      t.integer :group_id
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :booth_videos
  end
end
