module EventStreamHelper

  def display_event(event)
    { :avatar => link_to_avatar_for_event(event),
      :who => event_who_text(event),
      :what => event_what_text(event) }
  end
  
  def link_to_avatar_for_event(event, options={})
    photo = primary_photo_for(event, :size => '80x80', :hide_status_indicator => false, :hide_sponsor_sash => true)
    path = event.group_id ? group_event_path(event) : profile_path(event.profile)
    
    link_to photo, path
  end
  
  def event_path(event)
    if event.group_id
      group_event_path(event)
    else
      case event.klass
        when "Answer": question_path(:id => event[:answer_question_id])
        when "Question": question_path(:id => event.klass_id)
        when "GroupMembership": group_path(:id => event.group_id)
        when "BlogPost": "/blog_posts/#{event.klass_id}"
        when "Comment": "/comments/#{event.klass_id}"
        else
          profile_path(event.profile)
      end
    end
  end
  
  def group_event_path(event)
    group_path(:id => event.group_id)
  end
  
  def event_who_text(event)
    if event.group_id
      event.group_name
    else
      event.profile_screen_name
    end
  end
  
  def event_what_text(event)
    text = []
    if event.group_id
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
     	  text << "updated some profile details"
      when 'ProfilePhoto': 
     	  text << "updated a profile photo"
      when 'Answer': 
     	  text << "answered a question:"
     	  text << truncate(event[:answer_answer],100)
      when 'Question': 
     	  text << "asked a question:"
     	  text << truncate(event[:question_question],100)
      when 'Login': 
     	  text << "logged in"
      when 'GroupMembership': 
     	  text << "joined a group:"
     	  text << truncate(event.group_name,100)
      when 'BlogPost': 
     	  text << "added a blog post:"
     	  text << truncate(event.blog_post_title,100)
      when 'Comment': 
     	  text << "added a comment:"
     	  text << truncate(event.comment_text,100)
      when 'ProfileAward': 
     	  text << "received an award:"
     	  text << truncate(event.award_title,100)
      when 'Status': 
     	  text << "shared an update:"
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
  

end