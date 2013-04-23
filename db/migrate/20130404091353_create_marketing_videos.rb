class CreateMarketingVideos < ActiveRecord::Migration
  def self.up
    create_table :marketing_videos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :marketing_videos
  end
end
