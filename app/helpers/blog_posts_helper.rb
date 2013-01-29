module BlogPostsHelper
  def full_post?(blog_posts)
    true if (blog_posts.size == 1 && blog_posts.total_pages ==1 )
  end
  
  def posted_by(blog_post)
    blog_post.profile.screen_name + ", " + blog_post.creator.description 
    rescue 
      blog_post.profile.full_name
  end
end