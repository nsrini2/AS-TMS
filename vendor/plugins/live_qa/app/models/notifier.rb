class Notifier < ActionMailer::Base
  helper :email, :application
  layout 'email'
  
  def live_qa_rsvp(participant, chat, server_host )
    default_url_options[:host] ||= server_host
    @recipients  = participant.profile.user.email
    if participant.status == 'rsvp'
      @subject = "RSVP Confirmed: Chat Event \"#{chat.title}\""
      @headline = "Your RSVP for Chat Event \"#{chat.title}\" has been confirmed."
    else
      @subject = "Cancelation Confirmed: Chat Event \"#{chat.title}\"."
      @headline = "Your cancelation for Chat Event \"#{chat.title}\" has been confirmed."
    end 
    self.body = {:headline => @headline, :chat => chat  }   
  end
  
  def chat_update(chat)
    @subject = "AgentStream Chat Event \"#{chat.title}\" has been updated"
    self.body = {:headline => @subject, :chat => chat  }
  end

end
