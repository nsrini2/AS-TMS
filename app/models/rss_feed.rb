class RssFeed < ActiveRecord::Base
  belongs_to :blog
  belongs_to :profile
  
  scope :available, where("active <= '1' ")
  scope :active, where("active = '1'")
  
  validates :description, :presence => true
  validates :feed_url, :presence => true
  validates :blog_id, :presence => true
  validates :profile_id, :presence => true
  
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
  
  
  def toggle_activation
     toggle!(:active)
  end
  
  class << self
    def pull_to_blogs
      active.each do |feed|
        feed.add_blog_posts
      end  
    end
  end
end
