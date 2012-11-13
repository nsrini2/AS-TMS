require_cubeless_engine_file :model, :comment

class Comment
  include Notifications::Comment
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  # default_scope :conditions => ["blogs.owner_type <> 'company' "], :include => :blog
  stream_to :company, :activity
  after_save  :touch_owner
  
  def touch_owner
    owner.touch!
    rescue Exception
      
  end
  
  def destroy
    self.active = 0
    self.save!
    Rails.logger.info "Comment #{id} had active set to 0"
    # need to find a way to include this into the stream_to abstraction
    remove_from_company_stream
  end
  
  def company?
    self.owner.respond_to?(:company?) && self.owner.company?
  end

  def company_id
    if self.company?
      self.owner.company_id
    end  
  end

end