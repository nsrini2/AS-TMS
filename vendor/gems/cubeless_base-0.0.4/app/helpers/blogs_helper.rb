module BlogsHelper

  def blog_title(blog, blog_posts_on_page)
    if blog_posts_on_page.size == 1
      "#{blog_posts_on_page[0].title}"
    else
      if blog.owner.is_a?(Profile)
        blog.owner == current_profile ? "My Blog" : "#{blog.owner.full_name}'s Blog"
      else
        "Blog for #{blog.owner.name}"
      end
    end
  end

  def blogger_content(blog, &block)
    condition = bloggable(blog)
    return condition unless block_given?
    yield if condition
  end

  def bloggable(blog)
    (blog.owner.is_a?(Group) ? blog.owner.is_member?(current_profile) : current_profile == blog.owner)
  end

  def profile_blog_content(owner)
    yield if owner.is_a?(Profile) && controller.controller_name == 'blogs'
  end

  def group_blog_content(owner)
    yield if owner.is_a?(Group)
  end

  def empty_blog_content_for_non_blogger(blog, &block)
    yield if !bloggable(blog) and blog.blog_posts.size.zero?
  end

  def link_to_archive(owner, archive)
    owner = :companies if owner.class == Company
    link_to_if(params[:date] != archive.created_at_year_month.to_s, archive.created_at.strftime("%B %Y"), "#{polymorphic_path([owner, :blog])}?date=#{archive.created_at_year_month}")
  end

  def link_to_tag(owner, tag, count=false)
    owner = :companies if owner.class == Company
    name = tag.is_a?(Tag) ? tag.name : tag
    total = count && tag.is_a?(Tag) && tag.attributes['total']
    link_to_if(params[:tag] != name, name + (count ? "&nbsp;(#{total})" : ""), "#{polymorphic_path([owner, :blog])}?tag=#{name}")
  end

  def link_to_tags(owner, tags)
    result = []
    tags.sort.each do |tag|
      result << link_to_tag(owner, tag)
    end
    result.join(', ')
  end

  def link_to_edit_blog_post(owner, blog_post)
    owner = :companies if owner.class == Company
    link_to('edit', polymorphic_url([owner, :blog, blog_post], :action => :edit))
  end

  def link_to_delete_blog_post(blog_post)
    link_to('delete', blog_post_path(blog_post), :class => 'modal delete') if blog_post.deletable_by?(current_profile)
  end

  def rate_blog_post(blog_post, rating)
    options = { :class => "selected" } if (blog_post.user_has_rated ? blog_post.user_rating == rating : blog_post.rating_avg.round == rating)
    link_to(rating, rate_blog_post_path(:id => blog_post.id, :rating => rating), options)
  end

end