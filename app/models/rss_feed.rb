class RssFeed < ActiveRecord::Base
  belongs_to :blog
  belongs_to :profile
  # has_one :rss_feed_photo, :as => :owner, :dependent => :destroy
  belongs_to :primary_photo, :class_name => 'RssFeedPhoto', :foreign_key => :primary_photo_id
  
  has_many :blog_posts, :as => :creator
  
  scope :available, where("active <= '1' ")
  scope :active, where("active = '1'")
  
  validates :description, :presence => true
  validates :feed_url, :presence => true
  validates :blog_id, :presence => true
  validates :profile_id, :presence => true
  

  def primary_photo_path(which=:thumb)
    primary_photo.public_filename(which) if !primary_photo.nil?
  end
  
  class Feedzirra::Parser::RSSEntry
    element :source, :as => :source
  end  
  
  def add_blog_posts
    feed = Feedzirra::Feed.fetch_and_parse(self.feed_url)
    feed.entries.each do |entry|
      unless BlogPost.exists? :guid => entry.id
        entry.extend AgentStreamExtensions::Sample
        BlogPost.create(
          :creator_id   => self.id,
          :creator_type => self.class.to_s,
          :blog_id      => self.blog_id,
          :tagline      => self.tagline,
          :guid         => entry.id,
          :title        => entry.sample(:title),
          :text         => entry.sample(:content, :summary),
          :created_at   => entry.sample(:published),
          :source       => entry.sample(:source, :author),
          :link         => entry.sample(:url),
          :tag_list     => entry.sample(:categories)
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
