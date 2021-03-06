module GroupsHelper

  def group_icon(group)
    if group.is_public?
      image_tag("/images/icon_open.png", :alt => "This is a public group", :class => "group_icon")
    elsif group.is_invite_only?
      image_tag("/images/icon_inviteonly.png", :alt => "This group is invitation only", :class => "group_icon")
    elsif group.is_private?
      image_tag("/images/icon_private.png", :alt => "This group is private", :class => "group_icon")
    end
  end

  def link_to_accept_invitation_for(group)
    primary_small_button('Accept', join_group_path(group))
    link_to('Accept', join_group_path(group), :class => "button little accept")
  end

  def link_to_decline_invitation(invitation)
    link_to('Decline', group_invitation_path(invitation), :class => "button little light decline")
  end

  def member_since_display(profile,group)
    short_date(profile.joined(group).on)
  end

  def link_for_group(group)
    link_to(group.name, group_path(group.id), :id => 'group_' + group.id.to_s)
  end


  def calc_tag_classes(tag,minoccurs,maxoccurs)
    classes=%w(tag0 tag1 tag2 tag3 tag4)
    div=((maxoccurs-minoccurs)/classes.size) + 1
    weight = ((tag[:count]-minoccurs)/div).round
    tag_class=classes[weight]
  end  

  def link_to_booth_tag(owner, tag, minoccurs, maxoccurs)
      tag_class=calc_tag_classes(tag,minoccurs,maxoccurs)
      content_tag(:a, tag[:text], {:href => "#{polymorphic_path([owner, :blog])}?tag=#{tag[:text]}", :title =>"Tag Cloud", :class => "#{tag_class}" })
      #link_to(tag[:text], "#{polymorphic_path([owner, :blog])}?tag=#{tag[:text]}", :class => 'booth_tag_'+"{#tag_size}")
  end

  def group_member_or_public_content(group, &block)
    return group.is_member?(current_profile) || !group.is_private? || current_profile.has_role?(Role::ShadyAdmin) unless block_given?
    # yield if group.is_member?(current_profile) || !group.is_private? || current_profile.has_role?(Role::ShadyAdmin)
    block_text = capture(&block)
    block_text if group.is_member?(current_profile) || !group.is_private? || current_profile.has_role?(Role::ShadyAdmin)
  end

  def group_member_content(group, &block)
    # yield if group.is_member?(current_profile)
    block_text = capture(&block)
    block_text if group.is_member?(current_profile)
  end

  def group_member_or_shady_admin_content(group, &block)
    # yield if current_profile.has_role?(Role::ShadyAdmin) || group.is_member?(current_profile)
    block_text = capture(&block)
    block_text if current_profile.has_role?(Role::ShadyAdmin) || group.is_member?(current_profile)
  end

  def booth_admin_or_shady_or_cubeless_admin_content(group, &block)
    # yield if current_profile.has_role?(Role::ShadyAdmin) || current_profile.has_role?(Role::CubelessAdmin) ||  group.is_group_admin?(current_profile)
    block_text = capture(&block)
    block_text if group.is_group_admin?(current_profile) || current_profile.has_role?(Role::ShadyAdmin) || current_profile.has_role?(Role::CubelessAdmin)
  end

  def non_private_content(group, &block)
    # yield unless group.is_private?
    block_text = capture(&block)
    block_text unless group.is_private?
  end

  def group_owner_content(group)
    yield if group.owner==current_profile
  end

  def group_owner_or_shady_admin_content(group)
    group.owner==current_profile || current_profile.has_role?(Role::ShadyAdmin)
  end

  def link_to_delete(group)
    link_to("delete", group_path(group), :class => "modal delete")
  end

  def link_to_select_moderator_option(text,option,selected,group=@group)
    link_to_unless(selected==option, text, moderator_settings_group_path(group, :moderator_option => option), :id => option, :class => "select_moderator_option") {|t| content_tag(:span, t) }
  end

  def link_to_assign_moderator(text,profile,group=@group)
    link_to_unless(group.owner_id==profile.id, text, assign_moderator_group_path(group, :profile_id => profile.id), :class=>text) {''}
  end

  def link_to_assign_owner(profile, group=@group )
    link_to_unless(group.owner_id==profile.id, "make owner!", assign_owner_group_path(group, :profile_id => profile.id)) {''}
  end

  def link_to_remove_member(profile, group=@group)
    if group_owner_or_shady_admin_content(group)
      link_to("remove member", remove_member_group_path(group, :profile_id => profile.id), :class => "modal remove_member") unless group.owner == profile
    end
  end

  def render_navigation_thumbnails(photo)
    previous_photo = photo.find_previous
    next_photo = photo.find_next

    thumbs = []
    
    if previous_photo.blank? 
      thumbs << '<span class="at_first_photo">You are at the first&nbsp;photo</span>'
    else
      thumbs << link_to(image_tag(previous_photo.gallery_photo_attachment.public_filename(:small_thumb), :height => 90, :width => 90, :alt => "Previous"), group_gallery_photo_url(@group, previous_photo), :class=>"thumbnail_link")
    end

  	thumbs << image_tag(photo.gallery_photo_attachment.public_filename(:small_thumb), :height => 90, :width => 90, :alt => "Current", :class => "current thumbnail_link")
    
    if next_photo.blank?
      thumbs << '<span class="at_last_photo">You are at the last&nbsp;photo</span>'
  	else
  	  thumbs << link_to(image_tag(next_photo.gallery_photo_attachment.public_filename(:small_thumb), :height => 90, :width => 90, :alt => "Next"), group_gallery_photo_url(@group, next_photo), :class=>"thumbnail_link")
    end

  	thumbs
  end
end
