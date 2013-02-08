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
        if self.user.srw_agent_id.to_i != 0
          # Sabre Red User -- They get Sabre Red Welcome email -- see user
          false
        elsif self.id_was.nil? && (self.status == 2 || self.status == 1) 
          # Admin Created Users -- manually created or bulk uploaded
          true
        else
          # if the user is active, but has never logged in does not use SSO and had a status <= 0
          # i.e. change a user from pending to active or activate_on_login
          self.new_user? && self.status_was.to_i <= 0
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
      self.after_create :fire_notifications
      self.send :include, Notifications::BatchMailer
    end
   
    
    module InstanceMethods
      def fire_notifications      
        if self.company?
          self.class.delay.send_company_blog_post(self.id)
        elsif self.group?
          self.class.delay.send_group_blog_post(self.id)
        elsif self.news?
          self.class.delay.send_news_blog_post(self.id)
        else
          # don't send emails for profile blogs :)
        end      
      end
    end
  
    module ClassMethods
      # class methods here
    end
  end
  
  module Question
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
   
    
    module InstanceMethods
      def fire_notifications      
        SemanticMatcher.default.match_question_to_profiles(self)
        Notifier.delay.send_question_match_notifications(self.id)     
      end
    end

  end
  
  module Answer
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
      self.after_update :fire_update_notifications
    end
   
    
    module InstanceMethods
      def fire_notifications      
        Notifier.deliver_answer_to_question(self) if self.question.per_answer_notification
        Notifier.deliver_watched_question_answer(self) unless self.question.watchers.collect {|watcher| watcher.email if watcher.watched_question_answer_email_status==1 }.compact.empty?
      end
      
      def fire_update_notifications
        q = ::Question.unscoped.find_by_id(self.question_id)
        Notifier.deliver_best_answer(self) if self.best_answer and self.attribute_modified?(:best_answer) and q.is_closed?
      end
    end

  end
  
  module Abuse
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
      self.send :include, Notifications::BatchMailer
    end
   
    module InstanceMethods
      def fire_notifications
        send_new_abuse_email      
      end
      
      def send_new_abuse_email
        recipients = ::Profile.include_shady_admins.collect { |admin| admin.email }
        tmail = Notifier.new_abuse
        self.class.send_batch_email(tmail, recipients)
      end  
    end
  end
  
  module Group
    extend ActiveSupport::Concern
    
    included do
      self.after_update :fire_update_notifications
    end
    
    module InstanceMethods
      def fire_update_notifications
        Notifier.deliver_group_owner(self) if self.attribute_modified?(:owner_id) 
      end
    end  
  end
  
  module GroupMembership
    extend ActiveSupport::Concern
    
    included do
      self.after_update :fire_update_notifications
    end
    
    module InstanceMethods
      def fire_update_notifications
        not_owner = self.profile_id!=self.group.owner_id
        Notifier.deliver_group_moderator(self) if self.moderator and not_owner and self.attribute_modified?(:moderator)
      end  
    end  
  end  
  
  module GroupInvitation
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
      self.after_update :fire_update_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_group_invitation(self) if self.receiver.group_invitation_email_status
      end
      
      def fire_update_notifications
        Notifier.deliver_group_invitation(self) if self.receiver.group_invitation_email_status
      end  
    end  
  end
  
  module GroupInvitationRequest
    extend ActiveSupport::Concern
    
    included do
      self.after_create :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_group_invitation_request(self)
      end
      
    end  
  end
  
  module GroupPost
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        self.delay.send_group_post
      end
    end  
  end
  
  module ProfileAward
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_profile_award(self)
      end
    end  
  end
  
  module Reply
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifier.deliver_reply(self) if self.answer.profile.new_reply_on_answer_notification
      end
    end  
  end
  
  module GetthereBooking
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        Notifiers::Travel.deliver_new_getthere_booking(self) if self.profile.travel_email_status && !self.past?
      end
    end  
  end
  
  module Comment
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        if self.belongs_to_group_blog_post? 
          Notifier.deliver_new_comment_on_group_blog_post(self)
        elsif self.belongs_to_group_post?
          Notifiers::Group.deliver_new_comment_on_group_post(self)
        elsif self.company?
          Notifier.deliver_new_comment_on_company_blog_post(self)
        else
          if self.root_parent_profile? && self.owner.root_parent.new_comment_on_blog_notification  
            Notifier.deliver_new_comment_on_blog(self)
          end     
        end
      end
    end  
  end
  
  module Note
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
    end
    
    module InstanceMethods
      def fire_notifications
        if self.receiver.is_a?(Group)
          self.delay.send_group_note
        else
          Notifier.deliver_note(self) if self.receiver.note_email_status==1
        end
      end
    end  
  end

  module QuestionReferral
    extend ActiveSupport::Concern
    
    included do
      self.after_save :fire_notifications
      self.send :include, Notifications::BatchMailer
    end
    
    module InstanceMethods
      def fire_notifications
        if self.owner.is_a?(Group)
          delay.send_group_referral_email
        end
      end
      
      def send_group_referral_email
        tmail = Notifier.group_referral(self)
        recipients = self.group.members.collect {|p| p.email }
        self.class.send_batch_email(tmail, recipients)
      end
    end  
  end
end  
