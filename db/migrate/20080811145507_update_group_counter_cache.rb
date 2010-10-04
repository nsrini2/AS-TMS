class UpdateGroupCounterCache < ActiveRecord::Migration
  def self.up
    execute "update blogs set blog_posts_count = (select count(*) from blog_posts where blogs.id = blog_posts.blog_id)"
  end

  def self.down
  end
end
