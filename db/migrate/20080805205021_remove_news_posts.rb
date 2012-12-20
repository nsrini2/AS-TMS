class RemoveNewsPosts < ActiveRecord::Migration
  
  # def self.up
  #   # add tmp col
  #   add_column :blog_posts, :old_news_post_id, :integer
  #   
  #   #### indices ####
  #   
  #   # add unique constraint on name column for tags
  #   add_index :tags, :name, :unique => true
  #   
  #   #### inserts ####
  #   
  #   # migrate news posts to blog posts
  #   execute "insert into blog_posts (created_at, updated_at, blog_id, profile_id, title, text, comments_count, created_at_year_month, old_news_post_id, cached_tag_list) select np.created_at, np.created_at, b.id, np.profile_id, left(np.title,255), concat_ws('<br />',np.message,np.url), np.comments_count, replace(left(np.created_at,7),'-',''), np.id, 'news' from news_posts np join blogs b on b.owner_id=np.group_id and b.owner_type='Group'"
  #   
  #   # insert tag for news if it doesn't already exist, then associate all ex-news posts to the news tag
  #   execute "insert ignore into tags (name) values ('news')"
  #   execute "insert into taggings (tag_id, taggable_id, taggable_type, created_at) select (select tags.id from tags where tags.name='news'), bp.id, 'BlogPost', bp.created_at from blog_posts bp where bp.old_news_post_id is not null"
  #   
  #   # migrate votes to ratings
  #   execute "insert into ratings (rater_id, rated_id, rated_type, rating) select votes.profile_id, bp.id, 'BlogPost', case votes.vote_value when 1 then 5 else 1 end from votes, blog_posts bp where votes.owner_id=bp.old_news_post_id and votes.owner_type='NewsPost'"
  #   
  #   #### updates ####
  #   
  #   # update rating totals on the blog_post record
  #   execute "update blog_posts bp join (select rated_id, count(1) as r_count, sum(rating) as r_sum, avg(rating) as r_avg from ratings where rated_type='BlogPost' group by rated_id) as r on rated_id=bp.id set rating_count=r.r_count, rating_total=r.r_sum, rating_avg=r.r_avg where bp.old_news_post_id is not null"
  # 
  #   # update comments to reflect new blog post id and type
  #   execute "update comments, blog_posts bp set comments.owner_type='BlogPost', comments.owner_id=bp.id where comments.owner_type='NewsPost' and comments.owner_id=bp.old_news_post_id"
  # 
  #   # update activity_stream_events to reflect new blog post id and type
  #   execute "update activity_stream_events ase, blog_posts bp set ase.klass='BlogPost', ase.klass_id=bp.id where ase.klass='NewsPost' and ase.klass_id=bp.old_news_post_id"
  # 
  #   # update watch_events to reflect new blog post id and type
  #   execute "update watch_events, blog_posts bp set watch_events.action_item_type='BlogPost', watch_events.action_item_id=bp.id where watch_events.action_item_type='NewsPost' and watch_events.action_item_id=bp.old_news_post_id"
  #   
  #   # update abuses to reflect new blog post id and type
  #   execute "update abuses, blog_posts bp set abuses.abuseable_type='BlogPost', abuses.abuseable_id=bp.id where abuses.abuseable_type='NewsPost' and abuses.abuseable_id=bp.old_news_post_id"
  #   
  #   # update audits to reflect new blog post id and type
  #   execute "update audits, blog_posts bp set audits.auditable_type='BlogPost', audits.auditable_id=bp.id where audits.auditable_type='NewsPost' and audits.auditable_id=bp.old_news_post_id"
  #   
  #   #### deletes ####
  #   
  #   # delete old votes
  #   execute "delete from votes where owner_type='NewsPost'"
  #   
  #   # bye-bye news
  #   drop_table :news_posts
  #   
  #   # remove tmp col
  #   remove_column :blog_posts, :old_news_post_id
  # end
  # 
  # def self.down
  #   raise 'no going back!'
  # end
  
end