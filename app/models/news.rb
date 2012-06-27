require 'singleton'

class News
  include Singleton
  # should act as though it has_one blog
  NEWS_BLOG_ID = 10
  
  def blog
    Blog.find(NEWS_BLOG_ID)
  end
  
  def blog_posts
    blog.blog_posts
  end
  
  def private?
    false
  end
  
  class << self
    def find(*args)
      instance
    end
    
    def method_missing(method, *args, &block)
      if instance.respond_to? method
        if !args.empty?
          instance.send method, *args, &block
        else  
          instance.send method, &block
        end  
      else
        super
      end
    end
  end
end  