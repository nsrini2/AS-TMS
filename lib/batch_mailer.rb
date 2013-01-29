require "#{Rails.root}/vendor/plugins/cubeless/lib/batch_mailer"

class BatchMailer
  class << self
    alias  :orig_mail :mail

  
    def mail(model, whom)

      if model.class == Chat
        # here "Patched Mail"
        tmail = Notifier.create_chat_update(model)
        batch_me_up_scotty(tmail, whom)
      elsif model.respond_to?(:company?) && model.company?
        Logger.warn("Using BatchMailer with BlogPosts has been removed.  Use BlogPost.send_batch_email(tmail_object, recipients=[]) instead!")
        # tmail = Notifier.create_company_blog_post(model)
        #  batch_me_up_scotty(tmail, whom)
      else
        # here "Original Mail"
        orig_mail(model, whom)
      end    
    end
    
  end
  
end  