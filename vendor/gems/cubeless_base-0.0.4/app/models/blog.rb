class Blog < ActiveRecord::Base

  has_many :blog_posts, :order => "blog_posts.created_at desc", :dependent => :destroy

  has_many :archived_posts, :group => 'created_at_year_month',
    :order => 'created_at_year_month desc',
    :class_name => 'BlogPost'

  belongs_to :owner, :polymorphic => true

  def tags
    Tag.find_by_sql(["select tags.name, count(0) as total from taggings left join tags on tags.id = taggings.tag_id left join blog_posts on blog_posts.id = taggings.taggable_id and taggings.taggable_type = 'BlogPost' left join blogs on blogs.id = blog_posts.blog_id where blogs.id = '?' group by tags.name", self.id])
  end

end