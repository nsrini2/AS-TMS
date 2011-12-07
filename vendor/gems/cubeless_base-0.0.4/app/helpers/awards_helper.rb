module AwardsHelper
  
  def image_link_to_view_all_awards(profile)
    link_to(image_tag(profile.awards.default_or_last.award_image.public_filename(:preview), :width => 60, :height => 60, :class => "award_preview_image"), awards_popup_profile_path(profile), :class => "view_all_awards")
  end
  
  def award_image_for(award, which, opts={})
    image_tag(award.award_image.public_filename(which), opts) if award.award_image
  end
  
  def link_to_view_all_awards(profile)
    link_to("view all awards", awards_popup_profile_path(profile), :class => "modal view_all_awards" )
  end

  def award_caption(profile)
   "<span class=\"award_caption\">#{truncate(profile.awards.default_or_last.title, :length => 19)}</span>"
  end
  
  def link_to_toggle_award_visibility(award)
    link_text = award.visible ? "archive" : "unarchive"
    link_to(link_text, toggle_visibility_award_path(award), :class => link_text)
  end
  
  def link_to_archive_profile_award(profile_award)
    link_text = profile_award.visible ? "hide this award" : "make visible to others"
    link_to(link_text, toggle_visibility_profile_award_path(profile_award), :class => link_text.gsub(' ','_')
    )
  end
  
  def link_to_view_recipients(award)
    link_to_if(award.profiles.size > 0, "recipients (#{award.profile_awards.size})", "#", :class => "view_recipients")
  end

  def render_award(award)
    render :partial => 'awards/award', :locals => {:award => award}
  end

  def link_to_make_profile_award_default(profile_award)
    if profile_award.is_default?
      '<span class="clicked">default</span>'
    else
      link_to_if(!profile_award.is_default?, "make default", make_default_profile_award_path(profile_award), :class => "make_default") { "default" }
    end
  end
  
end