module ContentHelper

  def content_case(condition,&block)
    return condition unless block_given?
    # yield if condition
    block_text = capture(&block)
    block_text if condition
  end

  def centered_content(&block)
    concat(content_tag(:div, capture(&block), :style => "text-align: center; margin-top: 10px;"), block.binding)
  end

  def shady_admin_content(&block)
    return current_profile.has_role?(Role::ShadyAdmin) unless block_given?
    # yield if current_profile.has_role?(Role::ShadyAdmin)
    block_text = capture(&block)
    block_text if current_profile.has_role?(Role::ShadyAdmin)
  end

  def manual_login_content(&block)
    # yield if current_user.uses_login_pass?
    block_text = capture(&block)
    block_text if current_user.uses_login_pass?
  end

  def logged_in_content
    yield if logged_in?
  end

  def not_logged_in_content
    yield if !logged_in?
  end

  def owner_content(profile=@profile, &block)
    return current_profile==profile unless block_given?
    block_text = capture(&block)
    block_text if current_profile==profile
  end

  def owner_or_shady_admin_content(profile=@profile, &block)
    return current_profile == profile || current_profile.has_role?(Role::ShadyAdmin) unless block_given?
    # yield if current_profile == profile || current_profile.has_role?(Role::ShadyAdmin)
    block_text = capture(&block)
    block_text if current_profile == profile || current_profile.has_role?(Role::ShadyAdmin)
  end

  def karma_viewable_content(profile=@profile, &block)
    viewable = (owner_or_shady_admin_content || Config[:viewable_karma]) && (profile && profile.status >= 0)
    return viewable unless block_given?
    # yield if viewable
    block_text = capture(&block)
    block_text if viewable
  end

  def profile_completion_viewable_content(profile=@profile, &block)
    viewable = (owner_or_shady_admin_content && profile && profile.status >= 0)
    return viewable unless block_given?
    # yield if viewable
    block_text = capture(&block)
    block_text if viewable
  end

  def collection_content_for(collection, &block)
    if collection and collection.size > 0
      block.arity > 0 ? (yield collection) : yield
    end
  end

  def empty_collection_content_for(collection, &block)
    yield if collection.size.zero?
  end

  def object_editing_content(obj)
    return !obj.new_record? unless block_given?
    yield if !obj.new_record?
  end

  def object_creation_content(obj, &block)
    return obj.new_record? unless block_given?
    yield if obj.new_record?
  end

  # can use this with <%=f(var,value)%>, or <% f(var) do end %>
  def content_as_js_var(varname,value=nil,&block)
    return "<script>#{varname}='#{escape_javascript(value)}';</script>" unless block_given?
    concat("<script>#{varname}='#{escape_javascript(capture(&block))}';</script>",block.binding)
  end

  def object_edit_popup_content(object, author_content, shady_admin_content)
    return author_content if object.authored_by?(current_profile)
    shady_admin_content if current_profile.has_role?(Role::ShadyAdmin)
  end

  def object_edit_popup_title(object)
    object_edit_popup_content(object, "Oops I changed my mind!", "Community Managers Rock!")
  end

  def object_edit_popup_message(object, author_message)
    object_edit_popup_content(object, author_message, "Does the content demean, intimidate, or degrade?
    If so, zap it and leave a little note about why you changed it. If it's just dumb, you might consider leaving it, and
    trust the community to self correct the offender. Remember what Uncle Ben said \"With great power there must come
    great responsibility\"")
  end

  def author_content_for(object)
    return object.authored_by?(current_profile) unless block_given?
    yield if object.authored_by?(current_profile)
  end

  def author_or_shady_admin_content_for(object)
    return object.authored_by?(current_profile) || current_profile.has_role?(Role::ShadyAdmin) unless block_given?
    yield if object.authored_by?(current_profile) || current_profile.has_role?(Role::ShadyAdmin)
  end

  def editable_content_for(object)
    return object.editable_by?(current_profile) unless block_given?
    yield if object.editable_by?(current_profile)
  end

  def hide_for_sponsor(&block)
    return current_profile.is_sponsored? unless block_given?
    hide_content_for(Role::SponsorMember, &block)
  end

  def hide_when_viewing_sponsored_profile(profile=@profile,&block)
    puts "SPONSORED PROFILE HELPER"
    return profile.is_sponsored? unless block_given?
    # yield unless profile.is_sponsored?
    
    puts "BLOCK GIVEN"
    block_text = capture(&block)
    puts block_text
    puts profile.is_sponsored?
    block_text unless profile.is_sponsored?
  end
  
  # SSJ Depricated 1/17/2012
  # def show_when_viewing_sponsored_profile(profile=@profile, &block)
  #   return profile.is_sponsored? unless block_given?
  #   # yield if profile.is_sponsored?
  #   block_text = capture(&block)
  #   block_text if profile.is_sponsored?
  # end

  def show_for_sponsor(&block)
    return current_profile.is_sponsored? unless block_given?
    show_content_for(Role::SponsorMember, &block)
  end

end