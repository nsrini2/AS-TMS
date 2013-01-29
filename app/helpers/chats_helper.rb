module ChatsHelper
  # SSJ -- not sure I like having a return in the middle of the if statement
  def link_to_rsvp(chat)
    if chat.on_air?
        return link_to("Join Now", chat_path(chat), :class => "button large")
    elsif chat.host?(current_profile)
        return link_to("Start", chat_path(chat, :start => true), :class => "button large")
    elsif chat.is_participant?(current_profile)
      link = "Cancel RSVP"
      status = "canceled"
    else
      link = "RSVP"
      status = "rsvp"      
    end
                 
    link_to(link, rsvp_chat_path(chat, :profile_id => current_profile.id, :status => status), :class => "button large rsvp_link")
  end

  def list_topic(topic, current_profile) 
    buttons = topic_buttons(topic, current_profile)
    value = "<li class='topic'><span class='h5'>#{topic.title}</span>#{buttons}</li>"
  end

  def topic_buttons(topic, current_profile)
    if topic.mine?(current_profile)
      buttons = link_to("delete", chat_topic_path(topic.chat, topic), :confirm => 'Are you sure?', :class => "delete_topic button little")  
    else
      # buttons = link_to("up", "/", :class => "up button little light") 
      # buttons << " " + link_to("down", "/", :class => "down button little light")
      buttons = ""
    end
    buttons = "<span class='topic_buttons'>#{buttons}</span>"
  end

  def vote_up_image
    image_tag "/images/icons/as/vote-up.png", :alt => "Vote Up", :title => "Vote Up", :class => "vote vote_up"
  end
  def vote_down_image
    image_tag "/images/icons/as/vote-down.png", :alt => "Vote Down", :title => "Vote Down", :class => "vote vote_down"
  end

end