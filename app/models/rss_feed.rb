class RssFeed < ActiveRecord::Base
  scope :active, where("active = '1'")
  
  class Feedzirra::Parser::RSSEntry
    element :source, :as => :source
  end  
  
  def add_blog_posts
    feed = Feedzirra::Feed.fetch_and_parse(self.feed_url)
    feed.entries.each do |entry|
      unless BlogPost.exists? :guid => entry.id
        BlogPost.create(
          :profile_id   => self.profile_id,
          :blog_id      => self.blog_id,
          :guid         => entry.id,
          :title        => entry.title,
          :text         => entry.summary,
          :created_at   => entry.published,
          :source       => entry.source,
          :link         => entry.url,
          :tag_list     => entry.categories
        )
      end
    end
  end
  
  
  def self.pull_to_blogs
    active.each do |feed|
      feed.add_blog_posts
    end  
  end
end
