xml.document do
  xml.type('blogpost')
  xml.id("blogpost_#{blog_post.id}")
  xml.subject(blog_post.title)
  xml.blogentry(blog_post.text)
  xml.authortype(blog_post.blog.owner_type)
  profile = blog_post.profile.screen_name # this will create an n+1 query, but we should not have too many blog_posts
  if blog_post.news?
    xml.author(blog_post.source)
  else
    xml.author(profile)
  end
  xml.poster(profile)
  xml.tags(blog_post.cached_tag_list)
  xml.lineback(blog_post.link)
  xml.comments do
    blog_post.comments.each do |comment|
      xml.comment(comment.text)
    end
  end
  xml.security do
    if blog_post.blog.owner_type == "Group" && blog_post.blog.owner.private?
      xml.groupid("group_#{owner.id}") 
    end
    if blog_post.blog.owner_type == "Company" && 
      xml.groupid("company_#{blog_post.blog.owner.id}") 
    end
  end
end