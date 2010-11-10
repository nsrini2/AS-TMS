module MessagesHelper
  
  # MM2: Ok that's kind of a crappy name, but sometimes I want to show the sender, sometimes the reciever.
  # Also, apparently sometimes the receiver can be a group
  def display_message_person_of_interest(message)
    lead = ""
    img_person = nil
    img = nil
    
    if message.sender == current_profile
      if message.receiver.is_a?(Group)
        img_person = message.receiver
        lead = "To: " + link_to(message.receiver.name, group_path(message.receiver)) unless message.receiver.nil?
      else
        img_person = message.receiver
        lead = "To: " + link_to_profile(message.receiver, false) unless message.receiver.nil? # MM2: message.receiver.nil? happened once in my dev env...it scared me.
      end
    else
      img_person = message.sender
      lead = "From: " + link_to_profile(message.sender, false)
    end
    
    img = link_to_avatar_for(img_person, { :thumb => :thumb_80, :hide_status_indicator => true, :hide_sponsor_sash => true, :hide_tooltip => true }) if img_person
    
    { :img => img, :lead => lead }
  end

  
end