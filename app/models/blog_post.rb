require_cubeless_engine_file :model, :blog_post

class BlogPost
  include Notifications::BlogPost
  stream_to :company
  
  # named_scope :exclude_groups, lambda { |profile| { :conditions => ["groups.owner_id != ?", profile.id] } }
  default_scope order("blog_posts.created_at DESC")
  self.per_page = 5
  
  def group?
    self.blog.owner.class == Group
  end

  def company?
    self.blog.owner.class == Company
  end

  def company_id
    if self.company?
      self.blog.owner_id
    end  
  end

  
  def get_company_recipients(members)
    subscriptions = members.select { |member| member.company_blog_notification && !self.authored_by?(member) }
    subscriptions.collect { |subscription| subscription.email }
  end
  
  def self.send_company_blog_post(id)
    blog_post = BlogPost.find(id)
    recipients = blog_post.get_company_recipients(blog_post.blog.owner.members)
    # BatchMailer.mail(blog_post, recipients) unless recipients.blank?
    tmail = Notifier.create_company_blog_post(blog_post)
    self.send_batch_email(tmail, recipients)
  end

end