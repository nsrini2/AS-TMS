class SetCreatorOfRssFeeds < ActiveRecord::Migration
  def self.up
    creator_id = 1
    sql = <<-EOS
      UPDATE blog_posts 
      SET creator_id = #{creator_id}, creator = "RssFeed"
      WHERE guid IS NOT NULL
    EOS
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
  end
end
