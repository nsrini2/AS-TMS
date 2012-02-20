require "#{Rails.root}/vendor/plugins/live_qa/app/models/chat"

class Chat < ActiveRecord::Base
  include Notifications::BatchMailer
  # Refactor SSJ: I don't like this but...
  # This is to allow specific users the ability to create new live chats in addition to approved roles
  @@create_live_chat_event_exceptions = %w(
    scott.johnson@sabre.com
    Sarah.kennedy@sabre.com
    Kristin.evans@sabre.com
    Carrie.mamantov@sabre.com
    Karen.wright@sabre.com
    Natasha.sanchez@sabre.com
    Natasha.hayes@sabre.com
    Tina.shaffer@sabre.com
    Jennifer.petric@sabre.com
  )  
  
  def send_rsvp_email
    self.notifications_sent = 1
    save
    tmail = Notifier.chat_rsvp_reminder(self)
    recipients = participants.rsvp.collect { |p| p.email }
    Chat.send_batch_email(tmail, recipients)
  end
  
 
  class << self 
    def allowed_to_create?(profile)
      true if profile.has_role?(Role::CubelessAdmin) || @@create_live_chat_event_exceptions.include?(profile.user.email)
    end
    
    def send_rsvp_emails
      starting_soon.not_notified.each do |chat|
        chat.send_rsvp_email
      end  
    end
  end 
  
end