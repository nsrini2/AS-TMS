require_cubeless_engine_file :model, :blog_post

class BlogPost
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  # default_scope :conditions => ["blogs.owner_type <> 'company' "], :include => :blog
  
  
  def company?
    self.blog.owner.class == Company
  end

end