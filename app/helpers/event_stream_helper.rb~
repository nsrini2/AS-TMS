module EventStreamHelper

  def display_event(event)
    { :avatar => link_to_avatar_for_event(event),
      :who => event_who_text(event),
      :what => event_what_text(event),
      :icon => event_icon(event) }
  end
  
  def link_to_avatar_for_event(event, options={})
    photo = primary_photo_for(event, :thumb => :thumb_80, :hide_status_indicator => false, :hide_sponsor_sash => false)
    path = event.group_id ? group_event_path(event) : event.profile ? profile_path(event.profile) : ""
    
    link_to photo, path
  end
  
  def event_path(event)
    if event.group_id && !event.profile_id
      group_event_path(event)
    # elsif event.company_id && event.company_id > 0 
    #   case event.klass
    #     when "Answer": companies_question_path(:id => event[:answer_question_id])
    #     when "Question": companies_question_path(:id => event.klass_id)
    #     # when "GroupMembership": group_path(:id => event.group_id)
    #     # when "BlogPost": "/blog_posts/#{event.klass_id}"
    #     # when "Comment": "/comments/#{event.klass_id}"
    #     else
    #       event.profile ? profile_path(event.profile) : ""
    #   end
    else
      case event.klass
        when "Answer": company_or_question_path(event[:answer_question_id])
        when "Question": company_or_question_path(event.klass_id)
        when "GroupMembership": group_path(:id => event.group_id)
        when "BlogPost": "/blog_posts/#{event.klass_id}"
        when "Comment": "/comments/#{event.klass_id}"
        else
          event.profile ? profile_path(event.profile) : ""
      end
    end
  end
  
  def group_event_path(event)
    group_path(:id => event.group_id)
  end
  
  def event_who_text(event)    
    if event.group_id && !event.profile_id
      event.group_name
    elsif event.respond_to?(:profile_screen_name)
      event.profile_screen_name
    elsif event.respond_to?(:profile) && event.profile
      event.profile.screen_name
    else
      ""
    end
  end
  
  def event_what_text(event)
    text = []
    if event.group_id && !event.profile_id
      text << group_event_verb_text(event)
      text << group_event_what_text(event)
    else
      text << profile_event_what_text(event)
    end
    
    text.join(" ")
  end
  
  def profile_event_what_text(event)
    text = []
    case event.klass
      when 'Profile': 
     	  text << "updated profile details"
      when 'ProfilePhoto': 
     	  text << "updated profile photo"
      when 'Answer': 
     	  # text << "answered a question:"
     	  text << truncate(event[:answer_answer], { :length => 100, :omission => "..." })
     	  text << "<br/><span>[answer to \"#{truncate(event.answer_question_question, { :length => 60, :omission => "..." })}\"]</span>"
      when 'Question': 
     	  # text << "asked a question:"
     	  text << truncate(event[:question_question], { :length => 100, :omission => "..." })
      when 'Login': 
     	  text << "logged in"
      when 'GroupMembership': 
     	  # text << "joined a group:"
     	  text << truncate(event.group_name, { :length => 100, :omission => "..." })
      when 'BlogPost': 
     	  # text << "added a blog post:"
     	  text << truncate(event.blog_post_title, { :length => 100, :omission => "..." })
      when 'Comment': 
     	  text << truncate(event.comment_text, { :length => 100, :omission => "..." })
     	  text << "<br/><span>[comment on \"#{truncate(event.comment_blog_post_title, { :length => 60, :omission => "..." })}\"]</span>"
      when 'ProfileAward': 
     	  # text << "received an award:"
     	  text << truncate(event.award_title, { :length => 100, :omission => "..." })
      when 'Status': 
     	  # text << "shared an update:"
     	  text << event.status_body 	
    end     
    
    text.join(" ")
  end

  def group_event_verb_text(event)
    case event.klass
	    when 'Group': "was"
		  when 'GroupPhoto': "updated"
      else "was"
    end
  end
  
  def group_event_what_text(event)
    case event.klass
	    when 'Group': "#{event.action}d"
		  when 'GroupPhoto': "group photo"
      else "#{event.action}d"
    end    
  end
  
  
  def event_icon(event)     
    event_icon_path = case event.klass
                        when /Group/: group_icon_path
                        when "Status": status_icon_path
                        when /(Question|Answer)/: qa_icon_path
                        when /(Blog|Comment)/: blog_icon_path
                        when /Profile/: profile_icon_path
                      end
        
    icon_image(:path => event_icon_path) if event_icon_path
  end

end
