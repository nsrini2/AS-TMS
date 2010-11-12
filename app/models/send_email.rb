class SendEmail
  
  def set_values
    @group = Group.find_by_id(1)
    @user = User.find_by_id(3)
    @profile = @user.profile
    @answer = Answer.find_by_id(1)
    @best_answer = Answer.find_by_id(6)
  end
  
  def send_all_ducked
    send_welcome
    send_watched_question_answer
    send_summary
    send_retrievals
    send_referral
  end
  
  
  def send_welcome
    set_values
    Notifier.deliver_welcome(@user)
  end
  
  def send_watched_question_answer
    set_values
    Notifier.deliver_watched_question_answer(@answer)
  end
  
  def send_summary
    #  This uses a hacked up version of Notifier found only on Scott's computer -- SSJ
    Notifier.send_weekly_summary_emails
  end
  
  def send_retrievals
    # forgot login
    retrieval = Retrieval.new
    retrieval.email = "scott.johnson@sabre.com"    
    retrieval.item = "login"
    begin
      Notifier.deliver_retrieval(retrieval)
    rescue Exception => e
      puts e
    end   
    # forgot password
    retrieval.login = "scott"
    retrieval.item = "password" 
    begin
      Notifier.deliver_retrieval(retrieval)
    rescue Exception => e
      puts e
    end
  end
    
  def send_referral
    # personal referral
    referral = QuestionReferral.find(:first, :conditions => {:owner_type => 'Profile'})
    begin
      Notifier.deliver_referral(referral)
    rescue Exception => e
      puts e
    end 
  end
  
end  