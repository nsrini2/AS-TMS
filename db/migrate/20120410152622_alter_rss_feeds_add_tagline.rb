class AlterRssFeedsAddTagline < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :tagline, :text
  end

  def self.down
    remove_column :rss_feeds, :tagline
  end
end
