require "#{Rails.root}/vendor/plugins/live_qa/app/models/chat"

class Chat < ActiveRecord::Base
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
  
 
  class << self 
    def allowed_to_create?(profile)
      true if profile.has_role?(Role::CubelessAdmin) || @@create_live_chat_event_exceptions.include?(profile.user.email)
    end
 
  end 
  
end