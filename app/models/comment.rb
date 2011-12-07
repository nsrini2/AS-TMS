require_cubeless_engine_file :model, :comment

class Comment
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  # default_scope :conditions => ["blogs.owner_type <> 'company' "], :include => :blog
  stream_to :company
  
  def company?
    self.owner.respond_to?(:company?) && self.owner.company?
  end

  def company_id
    if self.company?
      self.owner.company_id
    end  
  end

end