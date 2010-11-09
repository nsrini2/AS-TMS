module IconHelper
  def icon_image(options)
    path = options.delete(:path)
    
    options[:class] = [options[:class], "icon"].compact.join(" ")
    
    image_tag path, options
  end


  def icon_path
    "/images/icons/as"
  end
  def group_icon_path
    "#{icon_path}/user-group.png"
  end
  def status_icon_path
    "#{icon_path}/comment.png"    
  end
  def qa_icon_path
    "#{icon_path}/help.png"
  end
  def blog_icon_path
    "#{icon_path}/write-note.png"
  end
  def profile_icon_path
    "#{icon_path}/user.png"
  end
end