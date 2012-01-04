class GeneralObserver < ActiveRecord::Observer

  observe Comment, GroupPost, Note, Profile, ProfileAward, QuestionReferral, Reply, GetthereBooking

  @@monitor_after_create = Set.new([Comment, GroupPost, Note, Profile, ProfileAward, QuestionReferral, Reply, GetthereBooking])
  def after_create(model)
    return unless @@monitor_after_create.member?(model.class)
    case model
      # when Abuse
      #   recipients = Profile.include_shady_admins.collect { |admin| admin.email }
      #   BatchMailer.mail(model, recipients)
      # when Answer
      #   Notifier.deliver_answer_to_question(model) if model.question.per_answer_notification
      #   Notifier.deliver_watched_question_answer(model) unless model.question.watchers.collect {|watcher| watcher.email if watcher.watched_question_answer_email_status==1 }.compact.empty?
      # when BlogPost
      #   if model.blog.owner_type == 'Group'
      #     BlogPost.delay.send_group_blog_post(model.id)
      #   elsif model.blog.owner_type == 'Company'
      #     BlogPost.delay.send_company_blog_post(model.id)
      #   end
      when Comment      
        if model.belongs_to_group_blog_post? 
          Notifier.deliver_new_comment_on_group_blog_post(model)
        elsif model.belongs_to_group_post?
           Notifiers::Group.deliver_new_comment_on_group_post(model)
        elsif model.company?
          Notifier.deliver_new_comment_on_company_blog_post(model)
        else    
           if model.root_parent_profile? && 
              model.owner.root_parent.new_comment_on_blog_notification  
              Notifier.deliver_new_comment_on_blog(model)
           end        
        end       
      # when GroupInvitation
      #   Notifier.deliver_group_invitation(model) if model.receiver.group_invitation_email_status
      when GroupPost
        model.delay.send_group_post
      when Note
        if model.receiver.is_a?(Group)
          model.delay.send_group_note
        else
          Notifier.deliver_note(model) if model.receiver.note_email_status==1
        end
      # SSJ 10-11-2011  Moved to concerns/notifications.rb  
      # when Profile
      #   Notifier.deliver_welcome(model.user) if model.new_user?
      when ProfileAward
        Notifier.deliver_profile_award(model)
      # when Question
      #   SemanticMatcher.default.match_question_to_profiles(model)
      #   Notifier.delay.send_question_match_notifications(model.id)
      when QuestionReferral
        if model.owner.is_a?(Group)
          model.delay.send_group_question_referral
        else
          Notifier.deliver_referral(model) if model.owner.referral_email_status==1
        end
      when Reply
        Notifier.deliver_reply(model) if model.answer.profile.new_reply_on_answer_notification
      when GetthereBooking
        Notifiers::Travel.deliver_new_getthere_booking(model) if model.profile.travel_email_status && !model.past?
    end
  end

  # @@monitor_after_update = Set.new([])
  # def after_update(model)
  #   return unless @@monitor_after_update.member?(model.class)
  #   case model
  #     # when Answer
  #     #   q = Question.unscoped.find_by_id(model.question_id)
  #     #   notify_best_answer =  (q.is_closed?)  #model.profile.best_answer_email_status==1 
  #     #   Notifier.deliver_best_answer(model) if model.best_answer and model.attribute_modified?(:best_answer) and notify_best_answer
  #     # when Group
  #     #         Notifier.deliver_group_owner(model) if model.attribute_modified?(:owner_id)
  #     # when GroupMembership
  #     #   not_owner = model.profile_id!=model.group.owner_id
  #     #   Notifier.deliver_group_moderator(model) if model.moderator and not_owner and model.attribute_modified?(:moderator)
  #     # when GroupInvitation
  #     #          Notifier.deliver_group_invitation(model) if model.receiver.group_invitation_email_status
  #   end
  # end
  
  # SSJ 10-11-2011  Moved to concerns/notifications.rb
  # @@monitor_after_save = Set.new([Profile])
  # def after_save(model)
  #   return unless @@monitor_after_save.member?(model.class)
  #   case model
  #     when Profile
  #       # Notifier.deliver_welcome(model.user) if model.new_user? && model.status_was <= 0
  #   end
  # end


  private

  def get_group_recipients(model, memberships)
    subscriptions = memberships.select { |membership| membership.wants_notification_for?(model) && !model.authored_by?(membership.member) }
    subscriptions.collect { |subscription| subscription.member.email }
  end

end