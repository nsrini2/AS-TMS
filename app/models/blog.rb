require_cubeless_engine_file :model, :blog

class Blog
  # default_scope :conditions => ["owner_type <> 'company' "]
  
  def company?
    self.owner.class == Company
  end
  
end