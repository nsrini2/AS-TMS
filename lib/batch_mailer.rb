require "#{Rails.root}/vendor/plugins/cubeless/lib/batch_mailer"

class BatchMailer
  class << self
    alias  :orig_mail :mail

  
    def mail(model, whom)

      if model.class == Chat
        # here "Patched Mail"
        tmail = Notifier.create_chat_update(model)
        batch_me_up_scotty(tmail, whom)
      else
        # here "Original Mail"
        orig_mail(model, whom)
      end    
    end
  end
  
end  