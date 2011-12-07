require 'net/smtp'
require 'enumerator'

class BatchMailer
  #number of mails sent in one connection to the smtp server
  SENDING_BATCH_SIZE = 50
  #SMTP SERVER
  SMTP_SERVER = Config[:smtp_settings][:address]

  def self.mail(model, whom)
    case model
      when WatchEvent
        case model.action_item
          when BlogPost
            Logger.warn("Using BatchMailer with BlogPosts has been removed.  Use BlogPost.send_batch_email(tmail_object, recipients=[]) instead!")
            # tmail = Notifier.create_blog_post(model.action_item)
        end
      when BlogPost
        Logger.warn("Using BatchMailer with BlogPosts has been removed.  Use BlogPost.send_batch_email(tmail_object, recipients=[]) instead!")
        # tmail = Notifier.create_group_blog_post(model)
      when GroupPost
        tmail = Notifier.create_group_post(model)
      when Note
        tmail = Notifier.create_group_note(model)
      when QuestionReferral
        tmail = Notifier.create_group_referral(model)
      when Abuse
        tmail = Notifier.create_new_abuse
      when User
        tmail = Notifier.create_new_user(model)
    end
    batch_me_up_scotty(tmail, whom)
  end

  def self.group_mass_mail(group, sender, subject, body, recipients)
    tmail = Notifier.create_mass_mail_for_group(group, sender, subject, body)
    batch_me_up_scotty(tmail, recipients)
  end

  def self.mass_welcome_resend_mail(recipients)
    users = User.find(:all, :condition => ["email in (?)", recipients])
    tmail = Notifier.create_welcome
    batch_me_up_scotty(tmail, users)
  end


  private
  def self.batch_me_up_scotty(tmail_object, whom)
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