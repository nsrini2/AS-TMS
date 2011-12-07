class MassMail < ActiveForm

  attr_accessor :subject, :body, :test_enabled

  validates_presence_of :subject
  validates_presence_of :body
  
  class << self
    
    # WARNING:  MM2: This should really only be called in a background process or a rake task or something.
    #           Sending emails to each user of the community one at a time will take some time
    #           However, at this time it's better than the 'undiclosed recipients' + BCC model that was getting caught in spam filters
    def send_community_email(subject, body, options)      
      recipients = options[:test_enabled] ? Array(options[:current_profile_email]) : User.active_users_emails
      
      recipients.each { |r| Notifier.deliver_community_email(subject, body, r) }
    end
      
    
  end

end