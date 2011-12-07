module ChatsHelper
  # SSJ -- not sure I like having a return in the middle of the if statement
  def link_to_rsvp(chat)
    if chat.on_air?
	      return link_to("Join Now", chat_path(chat), :class => "button little")
	  elsif chat.host?(current_profile)
	      return link_to("Start", chat_path(chat, :start => true), :class => "button little")
    elsif chat.is_participant?(current_profile)
      link = "Cancel RSVP"
      status = "canceled"
  	else
      link = "RSVP"
      status = "rsvp"      
  	end
  	  	 		  	
    link_to(link, rsvp_chat_path(chat, :profile_id => current_profile.id, :status => status), :class => "button little rsvp_link")
  end
    
  def list_topic(topic, current_profile)
    value = topic.title
    if topic.mine?(current_profile)
      value << " " + link_to("delete", chat_topic_path(topic.chat, topic), :confirm => 'Are you sure?', :class => "delete_topic")
    end 
    "<li>#{value}</li>"   
  end


end
