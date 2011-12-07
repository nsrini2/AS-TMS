require_cubeless_engine_file :model, :blog

class Blog
  # default_scope :conditions => ["owner_type <> 'company' "]
  
  def company?
    self.owner.class == Company
  end
  
  alias :org_owner :owner
  
  def owner
    # SSJ 09-06-11 sometimes blog.owner returns an ActiveRecord::Relation
    # blog.owner(force_relod = true) returns an error
    # so we get this :( 
    if self.org_owner.class == "ActiveRecord::Relation".constantize
      my_class = self.owner_type.constantize
      my_class.find_by_id(self.owner_id)
    else
      self.org_owner  
    end  
  end
  
end