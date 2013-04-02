class Blog < ActiveRecord::Base

  has_many :blog_posts, :order => "blog_posts.created_at desc", :dependent => :destroy

  has_many :archived_posts, :group => 'created_at_year_month',
    :order => 'created_at_year_month desc',
    :class_name => 'BlogPost'

  belongs_to :owner, :polymorphic => true

  belongs_to :group

  def tags(limit=false)
    sql = <<-EOS
            SELECT tags.name, count(0) as total 
            FROM taggings LEFT JOIN tags on tags.id = taggings.tag_id 
            LEFT JOIN blog_posts ON blog_posts.id = taggings.taggable_id 
            AND taggings.taggable_type = 'BlogPost' 
            LEFT JOIN blogs ON blogs.id = blog_posts.blog_id 
            WHERE blogs.id = '#{self.id}' 
            GROUP BY tags.name
         EOS
    if limit      
      sql << " ORDER BY total DESC LIMIT #{limit} "  
    else
      sql << " ORDER BY tags.name"
    end 
    Tag.find_by_sql(sql)
  end

end
