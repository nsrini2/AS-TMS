require 'singleton'
require 'faster_csv'

class News
  include Singleton
  include Notifications::BatchMailer
  
  # should act as though it has_one blog
  # check to see if we are on agentstream.com or not
  # Using the Facebook APP_ID to determine this
  NEWS_BLOG_ID =  case FB_APP_ID 
                    when '191254297585014'
                      #production
                      37812
                    when '214583051896993'
                      #staging  
                      29373
                    else
                      #dev
                      10   
                  end
   
  NEWS_ID = 1
  
  def id
    NEWS_ID
  end
  
  def add_visitor(profile)
    visit = Visitation.find_or_create_by_owner_type_and_owner_id_and_profile_id(self.class.name, id,profile.id)
    visit.save! # for updated_at refresh
  end
  
  def visitors
    Visitation.find_all_by_owner_type_and_owner_id(self.class.name, id)
  end
  
  def blog
    Blog.find(NEWS_BLOG_ID)
  end
  
  def blog_posts
    blog.blog_posts
  end
  
  def top_posts(n=10)
    blog_posts.by_rank.limit(n)
  end
  
  def post_views
    last_month = Date.today.advance(:months => -1)
    posts = blog_posts.where(:created_at_year_month => last_month.strftime("%Y%m") )
    csv_string = FasterCSV.generate do |csv|
      posts.each do |post|
        csv << [post.views, post.creator.description, post.title, post.source, post.link]
      end
    end
  end
  
  def private?
    false
  end
  
  def followers
    NewsFollower.profiles
  end
  
  class << self
    def find(*args)
      instance
    end
    
    alias_method :first, :find
    alias_method :last, :find
    
    def method_missing(method, *args, &block)
      if method.to_s[/^find_/i]
        find(*args)
      elsif instance.respond_to? method
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