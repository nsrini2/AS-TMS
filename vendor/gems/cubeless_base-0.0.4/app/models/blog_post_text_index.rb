class BlogPostTextIndex < ActiveRecord::Base

  belongs_to :blog_post

  xss_terminate :except => self.column_names

end
