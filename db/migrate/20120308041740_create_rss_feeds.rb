class CreateRssFeeds < ActiveRecord::Migration
  def self.up
    create_table :rss_feeds do |t|
      t.integer :blog_id
      t.integer :profile_id
      t.string :feed_url
      t.string :last_etag
      t.string :description
      t.integer :active, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :rss_feeds
  end
end
