class PostsAreNowNewsPosts < ActiveRecord::Migration
  def self.up
    # remove_index :posts, :created_at
    # remove_index :posts, :group_id
    # remove_index :posts, :profile_id
    # remove_index :posts, :net_helpful
    # 
    # rename_table :posts, :news_posts
    # 
    # add_index :news_posts, :created_at
    # add_index :news_posts, :group_id
    # add_index :news_posts, :profile_id
    # add_index :news_posts, :net_helpful

  end

  def self.down
    # remove_index :news_posts, :created_at
    # remove_index :news_posts, :group_id
    # remove_index :news_posts, :profile_id
    # remove_index :news_posts, :net_helpful
    # 
    # rename_table :news_posts, :posts
    # 
    # add_index :posts, :created_at
    # add_index :posts, :group_id
    # add_index :posts, :profile_id
    # add_index :posts, :net_helpful

  end
end
