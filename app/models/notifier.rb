require_cubeless_engine_file :model, :notifier

class Notifier 
  helper :email
  
  
  def group_invitation(invite)
    @recipients  = invite.receiver.email
    @subject = "You've been invited to join a group"
    self.body = {:group => invite.group, :sender => invite.sender, :receiver => invite.receiver}
  end

  def group_moderator(group_membership)
    @recipients = group_membership.member.email
    @subject = "You are now a moderator of a group"
    self.body = { :member => group_membership.member, :group => group_membership.group, :group_url => url_for(:controller => :groups, :action => :show, :id => group_membership.group_id) }
  end
  
  def group_owner(group)
    @recipients = group.owner.email
    @subject = "You are now the owner of #{group.name}"
    self.body = { :group => group, :group_url => url_for(:controller => :groups, :action => :show, :id => group.id)}
  end
  
  def new_user(user)
    @subject = "A new user has signed up for #{Config[:site_name]}"
    self.body = {:user => user}
  end
  
  def profile_award(profile_award)
    profile = profile_award.profile
    @recipients  = profile.email
    @subject = "Congratulations #{profile.full_name}, you've been presented an award"
    self.body = {:award => profile_award.award, :profile => profile_award.profile}
  end
  
private  
  def prepare_welcome_email(user)
    if user.profile.has_role?(Role::SponsorMember)
      subject = "Welcome to #{Config[:site_name]}"
      content = "<p>You are now a sponsored member at #{Config[:site_name]}.</p>"
    else
      welcome_email = WelcomeEmail.get
      subject = welcome_email.subject
      content = welcome_email.content
    end
    if user.crypted_password.blank?
      user.generate_temp_crypted_password(7.days.from_now)
      user.save_without_validation
    end
    @subject = subject
    @recipients = user.email
    @bcc = Config[:monitor_email_address] if Config[:monitor_email_address]
    self.body = { :content => content, :login => user.login, :screen_name => user.profile.screen_name, :uses_password => user.uses_login_pass?, :has_password => !user.crypted_password.blank?, :password_set_link => url_for(:controller => 'retrievals', :action => 'password_reset', :id => user.id, :auth => user.temp_crypted_password ) }
  end
  
#////// // // // // // // // // // ///////////   
#///// Question Answer Logic Starts Here //// 
#///// // // // // // // // // // //////////____________________
  def answer_to_question(answer)
    @recipients  = answer.question.profile.email
    @subject = "Your question has been answered"
    self.body = {:question => answer.question, :answer => answer,
      :profile_url => url_for(:controller => :profiles, :action => :show, :id => answer.profile_id),
      :question_url => url_for(:controller => :questions, :action => :show, :id => answer.question_id),
    }
  end

  def best_answer(answer)
    @recipients  = answer.profile.email
    @subject = "Your answer has been marked as best answer"
    self.body = {:question => answer.question, :answer => answer}
  end

  def question_match(question_profile_match)
    profile = question_profile_match.profile
    question = question_profile_match.question
    @recipients = profile.email
    @subject = "You have been matched with a question we think you can answer"
    self.body = { :profile => profile, :question => question }
  end

  def question_summary(question)
    @recipients  = question.profile.email
    @subject = "Your question has been answered"
    self.body = {:question => question,
      :question_url => url_for(:controller => :questions, :action => :show, :id => question.id)}
  end

  def referral(referral)
    @recipients  = referral.owner.email
    @subject = "A question has been referred to you"
    self.body = {:referred_to => referral.owner, :referred_by => referral.referer, :question => referral.question}
  end

  def reply(reply)
    @recipients = reply.answer.profile.email
    @subject = "Your answer has been replied to"
    self.body = { :reply => reply, :question => reply.answer.question, :answer => reply.answer,
    :profile_url => url_for(:controller => :profiles, :action => :show, :id => reply.profile_id),
    :question_url => url_for(:controller => :questions, :action => :show, :id => reply.answer.question_id) }
  end
  
  def watched_question_answer(answer)
    @bcc = answer.question.watchers.collect {|watcher| watcher.email if watcher.watched_question_answer_email_status==1 }.compact
    @subject = "One of your watched questions has been answered"
    self.body = {:answer => answer, :question => answer.question, :answered_by => answer.profile,
    :answer_url => url_for(:controller => :answers, :action => :show, :id => answer.id)}
  end
  
  def close_reminder(question)
    @recipients = Profile.find(question.profile_id).email
    @subject = "Your Question Is Closing In 4 Days"
    self.body = {:question => question,
            :question_url => url_for(:controller => :questions, :action => :show, :id => question.id)}
  end
end