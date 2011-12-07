require 'active_support/concern'
require 'net/smtp'
require 'enumerator'

module Notifications
  module BatchMailer
    extend ActiveSupport::Concern
    #number of mails sent in one connection to the smtp server
    SENDING_BATCH_SIZE = 50
    #SMTP SERVER
    SMTP_SERVER = Config[:smtp_settings][:address]
    
    # included do
    #   
    # end
   
    
    module InstanceMethods
    end
  
    module ClassMethods
      def send_batch_email(tmail_object, whom=[])
        return if whom.blank?
        tmail = tmail_object
        recipients = whom
        exceptions = {}
        recipients.each_slice(SENDING_BATCH_SIZE) do |recipients_slice|
          Net::SMTP.start(SMTP_SERVER, 25) do |sender|
            recipients_slice.each do |recipient|
              tmail.to = recipient
              begin
                sender.sendmail tmail.encoded, tmail.from, recipient
              rescue Exception => e
                exceptions[recipient] = e 
                #needed as the next mail will send command MAIL FROM, which would 
                #raise a 503 error: "Sender already given"
                sender.finish
                sender.start
              end
            end
          end
        end
      end
      
    end
  end
  
  
  module Profile
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    # def included(base)
    #  base.send :include, InstanceMethods
    #  base.extend ClassMethods
    # end    
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_welcome(self.user) if self.should_receive_welcome_email?
 	    end
 	    
 	    def should_receive_welcome_email?
        if self.status == 2  && self.id_was.nil?
          # creating new user with status activate_on_login
          true
        elsif  self.user.srw_agent_id.to_i != 0
          # Sabre Red User -- They get Sabre Red Welcome email -- see user
          false
        else  
          # if the user is active, but has never logged in does not use SSO and had a status <= 0
          self.new_user? && self.status_was <= 0
        end  
      end

    end
  
    module ClassMethods
      # class methods here
    end
  end  
  
  module User
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_sabre_red_sso_welcome(self) if self.should_receive_sabre_red_welcome_email?
 	    end
 	    
      def should_receive_sabre_red_welcome_email?
        # this is in the User, not profile because _was did not return correct value when referenced by something other than self
        self.srw_agent_id.to_i != 0 && self.terms_accepted && !self.terms_accepted_was
      end
    end
  
    module ClassMethods
      # class methods here
    end
  end   
  
  module BlogPost
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
      self.send :include, Notifications::BatchMailer
    end
   
    
    module InstanceMethods
      def fire_notifications      
        if self.company?
          self.class.delay.send_company_blog_post(self.id)
        elsif self.group?
          self.class.delay.send_group_blog_post(self.id)  
        else
          # don't send emails for profile blogs :)
        end      
      end
    end
  
    module ClassMethods
      # class methods here
    end
  end
  
end  
