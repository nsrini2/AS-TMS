module CommentsHelper

  def comment_text(comment)
    truncated_auto_link(comment.text, 90)
  end

  def comment_or_reply(post)
    post.is_a?(GroupPost) ? "reply" : "comment"
  end

  def link_to_edit_comment(url)
    link_to("edit", url, :class => "modal edit_comment")
  end

  def link_to_leave_comment(post)
    link_to_remote("leave a #{comment_or_reply(post)}", :url => comments_poly_path(post, :comment, { :action => :new }), :method => :get, :html => { :class => "modal" })
  end

  def comments_poly_path(obj, comment, args={})
    options = obj.respond_to?(:root_parent) ? [obj.root_parent] : []
    options << obj.group if obj.is_a?(GalleryPhoto)
    options << :blog if obj.respond_to?(:blog)
    options << obj << comment
    args[:routing_type] = :path
    polymorphic_url(options,args)
  end

  def link_to_view_or_leave_comments(obj)
    link_to(obj.comments_count > 0 ? "#{comment_or_reply(obj).pluralize} (#{obj.comments_count})" : "leave comment", "javascript:void(0)",
      :onclick => remote_function( :url => comments_poly_path(obj, :comments),:method => :get))
  end

  def link_to_view_comments(obj)
    link_to_if(obj.comments_count > 0, "#{comment_or_reply(obj).pluralize} (#{obj.comments_count})", "javascript:void(0)",
      :onclick => remote_function( :url => comments_poly_path(obj, :comments),:method => :get))
  end

end