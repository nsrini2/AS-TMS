require "#{Rails.root}/vendor/gems/cubeless_base-0.0.4/lib/batch_mailer"
require "#{Rails.root}/app/models/notifier" # not sure if it is better to reference cubeless or agentstream version of this file
# SSJ 11/16/2010
#
# when using in consule do: require 'spec/mailer_send_helper'
#
# monkey punching - duck punching cannot happen inside another class
# these methods are not in cubeless, but help in testing ...
class BatchMailer
  def self.send_batch_mail(tmail)
    users = ["scott.johnson@sabre.com"]
    # here(tmail.charset)
    batch_me_up_scotty(tmail, users)
  end  
end

# these methods are in cubelss, but have too  many restrictions to make getting test data feasable.
class Notifier
  
  def self.send_summary_email(start_date,options={})
    profile = Profile.find_by_id(2)
    questions = Question.find(:all) 
    # instance_eval adds instance only methods
    profile.instance_eval do
      def num_new_answers
        1
      end  
      def num_matches
        1
      end
      def num_new_referrals
        1
      end
      def num_new_notes
        1
      end
      def num_needs_best_answer
        2
      end
    end  
    Notifier.deliver_summary_email(profile, questions, start_date)
  end
  
  def self.send_question_summary
    options = {:group => 'questions.id'}
    ModelUtil.add_joins!(options,"join answers a on a.question_id=questions.id")
    ModelUtil.add_selects!(options,"questions.*, count(1) as num_new_answers")
    # the following requires that the data in the db have updated timestamps, so I leave it out
    # ModelUtil.add_conditions!(options,"daily_summary_email=1 and a.created_at >= DATE_SUB(CURDATE(),INTERVAL 1 DAY) and a.created_at < CURDATE()")

    Question.find(:all, options).each do |question|
      Notifier.deliver_question_summary(question)
    end
  end
end  

class MailerSendHelper
  
  def send_generic_email
    recipients = ["scott.s.johnson@att.net"]
    subject = "Communíty widé sübject"
    body  = "Community wide body. with hâts"
    Notifier.deliver_generic_email(subject, body, recipients)
  end
  
  def send_generic_batch
    recipients = ["scott.johnson@sabre.com"]
    subject = "Sübject with áccents - Batch"
    body = "Bödy wíth hâts and stuff - Batch"
    tmail = Notifier.create_generic_email(subject, body, recipients)
    # tmail.charset ="utf-8"
    # tmail.charset ="iso-8859-1"
    BatchMailer.send_batch_mail(tmail)
  end
  
  
  def send_all
    send_welcome
    send_watched_question_answer
    send_summary
    send_retrievals
    send_referral
    send_question_summary
    send_question_match
    send_profile_award
    send_note
    send_new_user
    send_new_comment_on_group_blog_post
    send_new_comment_on_blog
    send_new_abuse
    send_group_mass_mail
    send_group_referral
    send_group_post
    send_group_owner
    send_group_moderator
    send_group_invitation
    send_group_blog_post
    send_feedback
    send_failed_sync_users
    send_community_email
    send_close_reminder
    send_blog_post
    send_best_answer
    send_api_key_requested_for
    send_answer_to_question
    send_group_new_comment_on_group_post
    send_chat_update
  end
  
  
  def send_welcome
    # set_values
    @user = User.find_by_id(3)
    Notifier.deliver_welcome(@user)
  end
  
  def send_watched_question_answer
    # set_values
    @answer = Answer.find_by_id(1)
    Notifier.deliver_watched_question_answer(@answer)
  end
  
  def send_summary
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
  
  def send_question_summary
    # @question = Question.find_by_id(5)
    Notifier.send_question_summary
  end
  def send_question_match
    question = QuestionProfileMatch.find_by_id(1)
    Notifier.deliver_question_match(question)
  end
  def send_profile_award
    pa = ProfileAward.find_by_id(1)
    Notifier.deliver_profile_award(pa)
  end
  def send_note
    note = Note.find_by_id(4)
    Notifier.deliver_note(note)
  end
  def send_new_user
    user = User.find_by_id(3)
    tmail = Notifier.create_new_user(user)
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_new_comment_on_group_blog_post
    comment = Comment.find_by_id(1)
    Notifier.deliver_new_comment_on_group_blog_post(comment)
  end
  
  def send_new_comment_on_blog
    comment = Comment.find_by_id(3)
    Notifier.deliver_new_comment_on_blog(comment)
  end
  
  def send_new_abuse
    tmail = Notifier.create_new_abuse
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_group_mass_mail
    group = Group.find_by_id(1)
    profile = Profile.find_by_id(4)
    tmail = Notifier.create_mass_mail_for_group(group, profile, "Mass Mail Subject", "Mass Mail Body")
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_group_referral
    qr = QuestionReferral.find_by_id(3)
    tmail = Notifier.create_group_referral(qr)
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_group_post
    gp = GroupPost.find_by_id(1)
    tmail = Notifier.create_group_post(gp)
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_group_owner
    group = Group.find_by_id(1)
    Notifier.deliver_group_owner(group)
  end
  
  def send_group_moderator
    membership = GroupMembership.find_by_id(1)
    Notifier.deliver_group_moderator(membership)
  end
  
  def send_group_invitation
    invitation = GroupInvitation.find_by_id(1)
    Notifier.deliver_group_invitation(invitation)
  end
  
  def send_group_blog_post
    blog_post = BlogPost.find_by_id(1)
    tmail = Notifier.create_group_blog_post(blog_post)
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_feedback
    feedback = Feedback.new
    feedback.email = 'scott.johnson@sabre.com'
    feedback.name = "Scott"
    feedback.subject = "Feedback Subject"
    feedback.body = "Feedback Body"
    Notifier.deliver_feedback(feedback)
  end
  
  def send_failed_sync_users
    fsj = UserSyncJob.find_by_id(1)
    Notifier.deliver_failed_sync_users(fsj)
  end
  
  def send_community_email
    recipients = ["scott.johnson@sabre.com"]
    subject = "Community wide subject"
    body  = "Community wide body. with hâts"
    Notifier.deliver_community_email(subject, body, recipients)
  end
  
  def send_close_reminder
    q = Question.find_by_id(5)
    Notifier.deliver_close_reminder(q)
  end
  
  def send_blog_post
    blog_post = BlogPost.find_by_id(4)
    tmail = Notifier.create_blog_post(blog_post)
    BatchMailer.send_batch_mail(tmail)
  end
  
  def send_best_answer
    a = Answer.find_by_id(6)
    Notifier.deliver_best_answer(a)
  end
  
  def send_api_key_requested_for
    profile = Profile.find_by_id(4)
    Notifier.deliver_api_key_requested_for(profile)
  end
  
  def send_answer_to_question
    answer = Answer.find_by_id(1)
    Notifier.deliver_answer_to_question(answer)
  end
  
  def send_group_new_comment_on_group_post
    c = Comment.find_by_id(7)
    Notifiers::Group.deliver_new_comment_on_group_post(c)
  end
  
  def send_chat_update
    chat = Chat.find_by_id(1)
    # here chat.title
    tmail = Notifier.create_chat_update(chat)
    BatchMailer.send_batch_mail(tmail)
  end
  
end