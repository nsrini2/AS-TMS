module MessagesHelper
  
  # MM2: Ok that's kind of a crappy name, but sometimes I want to show the sender, sometimes the reciever.
  # Also, apparently sometimes the receiver can be a group
  def display_message_person_of_interest(message)
    if message.sender == current_profile
      if message.receiver.is_a?(Group)
        "To: " + link_to(message.receiver.name, group_path(message.receiver)) unless message.receiver.nil?
      else
        "To: " + link_to_profile(message.receiver, false) unless message.receiver.nil? # MM2: message.receiver.nil? happened once in my dev env...it scared me.
      end
    else
      "From: " + link_to_profile(message.sender, false)
    end
  end
  
end