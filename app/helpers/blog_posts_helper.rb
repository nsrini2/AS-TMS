module BlogPostsHelper
  def full_post?(blog_posts)
    true if (blog_posts.size == 1 && blog_posts.total_pages ==1 )
  end
end