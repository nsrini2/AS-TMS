require 'uri'

class Notifier < ActionMailer::Base
  layout 'email'

  def initialize(method_name=nil, *parameters)
    # MM2: Now using builtin rails layouts
    # @layout = :email
    @from = Config[:email_from_address]
    headers 'Reply-To' => Config[:reply_to_address] if Config[:reply_to_address]
    # @content_type = "text/html; charset=iso-8859-1"
    @content_type = "text/html; charset=utf-8"
    super(method_name, *parameters)
  end

  # def weekly_status_report(recipient)
  #   data = StatusReport.weekly_dump
  #   filename = "AgentStream-weekly-#{Date.today.strftime("%Y-%m-%d")}.csv"
  #   mail.attachments[filename.to_s] = {
  #     :mime_type => "text/csv", 
  #     :content => data
  #   }
  #   mail(:from => Config[:email_from_address], :to => recipient, :subject => "AgentStream Weekly Report", :template_name => 'attachment')  
  # end

  def monthly_activity_report(recipient)
    data = StatusReport.monthly_activity_report
    filename = "AgentStream-monthly-activity-#{(Date.today.advance(:months => -1)).strftime("%Y-%m")}.csv"
    mail.attachments[filename.to_s] = {
      :mime_type => "text/csv", 
      :content => data
    }
    mail(:from => Config[:email_from_address], :to => recipient, :subject => "AgentStream Monthly ActivityReport", :template_name => 'attachment')
  end
  
  def users_by_country_report(recipient)
    data = StatusReport.users_by_country
    filename = "AgentStream-users-by-country.csv"
    mail.attachments[filename.to_s] = {
      :mime_type => "text/csv", 
      :content => data
    }
    mail(:from => Config[:email_from_address], :to => recipient, :subject => "AgentStream Users By Country Report", :template_name => 'attachment')
  end

  def api_key_for(requester)
    @recipients  = requester.email
    @subject = "Your API key"
    self.body = {:profile => requester}
  end

  def api_key_requested_for(profile)
    @recipients  = Config[:feedback_email]
    @subject = "API key requested"
    self.body = {:profile => profile}
  end

  def blog_post(blog_post)
    @subject = "#{blog_post.root_parent.screen_name} just wrote a new blog post."
    self.body = {:blog_post => blog_post, :author => blog_post.root_parent}
  end

  def feedback(feedback)
    @recipients = Config[:feedback_email]
    @subject = "#{Config[:site_name]} Feedback | #{feedback.name} | #{feedback.subject}"
    headers 'Reply-To' => feedback.email
    self.body = {:name => feedback.name, :email => feedback.email, :body => feedback.body.gsub(/\r?\n/,'<br/>')}
  end

  def group_blog_post(blog_post)
    @subject = "A new blog post has been added to #{blog_post.blog.owner.name}."
    self.body = {:blog_post => blog_post, :group => blog_post.blog.owner}
  end

  def group_invitation(invite)
    @recipients  = invite.receiver.email
    @subject = "You've been invited to join a group!"
    self.body = {:group => invite.group, :sender => invite.sender, :receiver => invite.receiver}
  end

  def group_moderator(group_membership)
    @recipients = group_membership.member.email
    @subject = "You are now a moderator of a group!"
    self.body = { :member => group_membership.member, :group => group_membership.group, :group_url => url_for(:controller => :groups, :action => :show, :id => group_membership.group_id) }
  end

  def group_note(note)
    @subject = "#{note.receiver.name} just received a note."
    self.body = {:note => note, :group => note.receiver}
  end

  def group_owner(group)
    @recipients = group.owner.email
    @subject = "You are now the owner of #{group.name}!"
    self.body = { :group => group, :group_url => url_for(:controller => :groups, :action => :show, :id => group.id)}
  end

  def group_post(post)
    @subject = "#{post.group.name} just got a new group talk post."
    self.body = {:post => post, :group => post.group}
  end

  def group_referral(referral)
    @subject = "#{referral.owner.name} has been referred a question."
    self.body = {:group => referral.owner, :referred_by => referral.referer, :question => referral.question}
  end
 
  def community_email(subject, body, recipients)
    @subject = subject
    self.body = {:mail_body => body}
    @recipients = recipients
  end

  def mass_mail_for_group(group, sent_by, subject, body)
    @subject = subject
    self.body = {:mail_body => body, :sent_by => sent_by, :group => group }
  end

  def new_abuse
    @subject = "A new item has been marked as inappropriate"
    self.body = {}
  end
  
  def new_comment_on_blog(comment)
    @recipients = comment.owner.root_parent.email
    @subject = "#{comment.owner.title} just received a new comment."
    self.body = { :comment => comment }
  end
  
  def new_comment_on_group_blog_post(comment)
    @recipients = comment.owner.profile.email
    @subject = "#{comment.owner.title} just received a new comment."
    self.body = { :comment => comment }
  end
  
  def new_user(user)
    @subject = "A new user has signed up for #{Config[:site_name]}!"
    self.body = {:user => user}
  end

  def note(note)
    @recipients = note.receiver.email
    @subject = "You just received a new note."
    self.body = {:note => note, :sender => note.sender, :receiver => note.receiver}
  end

  def profile_award(profile_award)
    profile = profile_award.profile
    @recipients  = profile.email
    @subject = "Congrats #{profile.full_name}! You've been presented an award!"
    self.body = {:award => profile_award.award, :profile => profile_award.profile}
  end

  def retrieval(retrieval)
    @subject = "Your requested information."
    prepare_login_retrieval(retrieval) if retrieval.item == 'login'
    prepare_password_retrieval(retrieval) if retrieval.item == 'password'
  end

  def welcome(user)
    prepare_welcome_email( user )
  end

  def summary_email(profile, questions, start_date)
    @recipients  = profile.email
    @subject = "#{Config[:site_name]} Activity Summary"
    self.body = {:profile => profile, :questions => questions, :start_date => start_date,
        :profile_url => url_for(:controller => "profiles", :action => "show", :id => profile.id)
    }
  end
  
  def failed_sync_users(user_sync_job)
    @recipients = "support@cubeless.com"
    @subject = "A failed User Sync has been detected"
    self.body = {:user_sync_job => user_sync_job}
  end

  def self.send_daily_summary_emails
    send_summary_email(Date.today-1,{ :conditions => 'summary_email_status=2 and status != 2'})
  end

  def self.send_weekly_summary_emails
    send_summary_email(Date.today-7,{ :conditions => 'summary_email_status=1 and status != 2'})
  end

  def self.send_summary_email(start_date,options={})

    ModelUtil.add_selects!(options,"(select count(1) from answers a join questions q on q.id=a.question_id where q.profile_id=profiles.id and a.created_at>='#{start_date}') as num_new_answers")
    ModelUtil.add_selects!(options,"(select count(1) from question_profile_matches qpm where qpm.profile_id=profiles.id and qpm.order<=#{SemanticMatcher.question_match_max_assigned}) as num_matches")
    ModelUtil.add_selects!(options,"(select count(1) from question_referrals qr where qr.owner_id=profiles.id and qr.owner_type='Profile' and qr.created_at>='#{start_date}' and qr.active=1) as num_new_referrals")
    ModelUtil.add_selects!(options,"(select count(1) from notes n where n.receiver_id=profiles.id and n.created_at>='#{start_date}') as num_new_notes")
    ModelUtil.add_selects!(options,"(select count(1) from questions left join answers a on questions.id=a.question_id and a.best_answer=0 where questions.profile_id=profiles.id and questions.open_until<=now() and a.id is null and exists (select 1 from answers a2 where a2.question_id=questions.id limit 1)) as num_needs_best_answer")

    options[:having] = 'num_new_answers>0 or num_new_referrals>0 or num_new_notes>0 or num_needs_best_answer>0'

    Profile.active.find(:all,options).each do |profile|
      q_options = {}
      ModelUtil.add_joins!(q_options,"left join answers a on questions.id=a.question_id and a.best_answer>0")
      ModelUtil.add_selects!(q_options,"questions.*, (select count(1) from answers where question_id=questions.id) as num_answers")
      ModelUtil.add_conditions!(q_options,"questions.profile_id=#{profile.id} and questions.open_until<=now() and a.id is null and exists (select 1 from answers a2 where a2.question_id=questions.id and a2.profile_id!=questions.profile_id limit 1)")
      questions = Question.find(:all,q_options)

      Notifier.deliver_summary_email(profile, questions, start_date)
    end

  end

  def body=(options)
    @body = options.merge!(:site_base_url => site_base_url, :site_name => Config[:site_name], :theme_colors => Config['themes'][Config[:theme]], :site_logo => site_logo)
  end

  def url_for(options)
    options[:host] = site_host_port
    options[:protocol] = site_base_uri.scheme
    super(options)
  end

  # private
  def prepare_password_retrieval(retrieval)
    user = User.find(:first, {:conditions => ["login = ?", retrieval.login]})
    user.generate_temp_crypted_password(24.hours.from_now)
    user.save(:validate => false)
    @recipients = user.email
    self.body = {
      :login => user.login,
      :password => true, # denotes password was reset only
      :screen_name => user.profile.screen_name,
      :password_reset_link => url_for(:controller => "retrievals",
                                      :action => "password_reset",
                                      :id => user.id,
                                      :auth => user.temp_crypted_password)}
  end

  def prepare_login_retrieval(retrieval)
    @recipients = retrieval.email
    users = User.find_all_by_email(retrieval.email)
    logins = Array.new
    screen_names = Array.new
    users.each do |user|
      screen_names << user.profile.screen_name
      logins << user.login
    end
    self.body = {:logins => logins, :screen_names => screen_names}
  end
 
  def prepare_welcome_email(user)
    if user.profile.has_role?(Role::SponsorMember)
      subject = "Welcome to #{Config[:site_name]}!"
      content = "<p>You are now a sponsored member at #{Config[:site_name]}.</p>"
    else
      welcome_email = WelcomeEmail.get
      subject = welcome_email.subject
      content = welcome_email.content
    end
    if user.crypted_password.blank?
      user.generate_temp_crypted_password(7.days.from_now)
      user.save(:validate => false)
    end
    @subject = subject
    @recipients = user.email
    @bcc = Config[:monitor_email_address] if Config[:monitor_email_address]
    self.body = { :content => content, :login => user.login, :screen_name => user.profile.screen_name, :uses_password => user.uses_login_pass?, :has_password => !user.crypted_password.blank?, :password_set_link => url_for(:controller => 'retrievals', :action => 'password_reset', :id => user.id, :auth => user.temp_crypted_password ) }
  end

  def site_base_uri
    @@site_base_uri ||= URI.parse(Config[:site_base_url])
  end

  def site_base_url
    @@site_base_url ||= site_base_uri.to_s
  end

  def site_host_port
    @@site_host_port ||= site_base_url.match('//(.*)')[1]
  end
  
  # Copied from CssHelper
  def site_logo
    if Config[:logo_file].to_s.first == "/"
      Config[:logo_file].to_s
    else
      "/images/custom/" + Config[:logo_file]
    end
  end

#////// // // // // // // // // // ///////////   
#///// Question Answer Logic Starts Here //// 
#///// // // // // // // // // // //////////____________________
def answer_to_question(answer)
  @recipients  = answer.question.profile.email
  @subject = "Your question has been answered!"
  self.body = {:question => answer.question, :answer => answer,
    :profile_url => url_for(:controller => :profiles, :action => :show, :id => answer.profile_id),
    :question_url => url_for(:controller => :questions, :action => :show, :id => answer.question_id),
  }
end

def best_answer(answer)
  @recipients  = answer.profile.email
  @subject = "Your answer has been marked as best answer!"
  self.body = {:question => answer.question, :answer => answer}
end

def question_match(question_profile_match)
  profile = question_profile_match.profile
  question = question_profile_match.question
  @recipients = profile.email
  @subject = "You have been matched with a question we think you can answer!"
  self.body = { :profile => profile, :question => question }
end

def question_summary(question)
  @recipients  = question.profile.email
  @subject = "Your question has been answered!"
  self.body = {:question => question,
    :question_url => url_for(:controller => :questions, :action => :show, :id => question.id)}
end

def referral(referral)
  @recipients  = referral.owner.email
  @subject = "A question has been referred to you!"
  self.body = {:referred_to => referral.owner, :referred_by => referral.referer, :question => referral.question}
end

def reply(reply)
  @recipients = reply.answer.profile.email
  @subject = "Your answer has been replied to!"
  self.body = { :reply => reply, :question => reply.answer.question, :answer => reply.answer,
  :profile_url => url_for(:controller => :profiles, :action => :show, :id => reply.profile_id),
  :question_url => url_for(:controller => :questions, :action => :show, :id => reply.answer.question_id) }
end

def watched_question_answer(answer)
  @bcc = answer.question.watchers.collect {|watcher| watcher.email if watcher.watched_question_answer_email_status==1 }.compact
  @subject = "One of your watched questions has been answered."
  self.body = {:answer => answer, :question => answer.question, :answered_by => answer.profile,
  :answer_url => url_for(:controller => :answers, :action => :show, :id => answer.id)}
end

def generic_email(subject, body, recipients)
  @subject = subject
  self.body = {:mail_body => body}
  @recipients = recipients
end

def self.send_question_match_notifications(question_id = nil)
  qpms = question_id.nil? ? QuestionProfileMatch.all(:conditions => ['`order` <10 and notified = 0']) : QuestionProfileMatch.all(:conditions => ['`order` <10 and notified = 0 and question_id = ?', question_id])

  qpms.each do |match|
    if match.valid? # don't send emails to matches on invalid QuestionProfileMatches -- i.e. it is a company question and the profile is not in the company
      Notifier.deliver_question_match(match) && match.update_attribute(:notified, true)
      puts "Notified profile id #{match.profile_id} for question #{match.question_id}!"
    end  
  end
end

def self.send_question_summary
  options = {:group => 'questions.id'}
  ModelUtil.add_joins!(options,"join answers a on a.question_id=questions.id")
  ModelUtil.add_selects!(options,"questions.*, count(1) as num_new_answers")
  ModelUtil.add_conditions!(options,"daily_summary_email=1 and a.created_at >= DATE_SUB(CURDATE(),INTERVAL 1 DAY) and a.created_at < CURDATE()")

  Question.find(:all, options).each do |question|
    Notifier.deliver_question_summary(question)
  end
end

def close_reminder(question)
  @recipients = Profile.find(question.profile_id).email
  @subject = "Your Question Is Closing In 4 Days!"
  self.body = {:question => question,
          :question_url => url_for(:controller => :questions, :action => :show, :id => question.id)}
end

def self.send_close_reminder
  @question_summaries = Question.find_summary(:all, :conditions => ['open_until > current_date() and open_until = ?', Date.today + 4])
  @question_summaries.each do |question|
    Notifier.deliver_close_reminder(question)
  end
end

end