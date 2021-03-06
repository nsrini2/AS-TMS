class ActivityStreamEvent < ActiveRecord::Base
  include ActivityStreamInterface
  
  self.per_page = 15
  belongs_to :profile

  # MM2: I'm truly sorry for adding to this mess and not fixing it. (2010-07-20 - status additions)
  # SRIWW-19/Apr/13: Adding more joins to create additional activity stream events...
  def self.find_summary(*args)
    ModelUtil.add_joins!(args,"left join profiles on profiles.id=profile_id left join attachments pp on pp.id=profiles.primary_photo_id")
    ModelUtil.add_joins!(args,"left join groups on groups.id=group_id left join attachments gp on gp.id=groups.primary_photo_id")
    ModelUtil.add_joins!(args,"left join questions on activity_stream_events.klass='Question' and questions.id=klass_id")
    ModelUtil.add_joins!(args,"left join answers on activity_stream_events.klass='Answer' and answers.id=klass_id")
    ModelUtil.add_joins!(args,"left join group_posts on activity_stream_events.klass='GroupPost' and group_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join blog_posts on activity_stream_events.klass='BlogPost' and blog_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.id=klass_id") 
    ModelUtil.add_joins!(args,"left join comments on activity_stream_events.klass='Comment' and comments.id=klass_id")
    ModelUtil.add_joins!(args,"left join statuses on activity_stream_events.klass='Status' and statuses.id=klass_id")
    #SRIWW-19/Apr/13: This is causing duplicate group membership events to be displayed in all the activity streams
    #ModelUtil.add_joins!(args,"left join group_memberships on activity_stream_events.klass='GroupMembership' and group_memberships.group_id=activity_stream_events.group_id")
    ModelUtil.add_joins!(args,"left join profile_awards on activity_stream_events.klass='ProfileAward' and profile_awards.id=klass_id left join awards on profile_awards.award_id = awards.id")
    ModelUtil.add_joins!(args,"left join questions as answer_questions on activity_stream_events.klass='Answer' and answers.id=klass_id and answers.question_id=answer_questions.id")
    ModelUtil.add_joins!(args,"left join blog_posts as comment_blog_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'BlogPost' and comments.owner_id=comment_blog_posts.id")
    ModelUtil.add_joins!(args,"left join group_posts as comment_group_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'GroupPost' and comments.owner_id=comment_group_posts.id")
   ModelUtil.add_joins!(args,"left join questions as question_question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.owner_type='Group' and question_referrals.id=klass_id and question_referrals.question_id=question_question_referrals.id")
   ModelUtil.add_joins!(args,"left join questions as profile_question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.owner_type='Profile' and question_referrals.id=klass_id and question_referrals.question_id=profile_question_referrals.id")


   ModelUtil.add_selects!(args,"activity_stream_events.id"+
    ", activity_stream_events.created_at"+
    ", activity_stream_events.klass"+
    ", activity_stream_events.klass_id"+
    ", activity_stream_events.profile_id"+
    ", activity_stream_events.action"+
    ", activity_stream_events.group_id"+
    ", profiles.screen_name as profile_screen_name"+
    ", profiles.karma_points as profile_karma_points"+

    ", pp.filename as profile_photo_filename"+
    ", pp.id as profile_photo_id"+
    ", questions.question as question_question"+
    ", answers.answer as answer_answer"+

    ", answers.question_id as answer_question_id"+
    
    ", answer_questions.question as answer_question_question"+
    ", comment_blog_posts.title as comment_blog_post_title"+
    ", comment_group_posts.post as comment_group_post_post"+

    ", group_posts.post as group_post_post"+
    ", question_question_referrals.question as question_question_referral_question"+
    ", profile_question_referrals.question as profile_question_referral_question"+
    
    ", groups.name as group_name"+
    ", gp.filename as group_photo_filename"+

    ", gp.id as group_photo_id"+
    ", blog_posts.title as blog_post_title"+
    ", comments.text as comment_text"+
    ", statuses.body as status_body"+

    ", awards.title as award_title")
   
    
    # Do not display GroupMemberships of invisible people
    # I know...that sounds whack...but it has happened...
    ModelUtil.add_conditions!(args, ["(activity_stream_events.profile_id IS NULL OR (activity_stream_events.profile_id IS NOT NULL AND profiles.visible = ?))", true])

    options = ModelUtil.get_options!(args)
    options[:group] = 'activity_stream_events.klass, activity_stream_events.klass_id'
    options[:order] = 'created_at desc' unless options.member?(:order)
    
    # find(*args)
    args.shift if args.first.to_sym == :all
    self.paginate(*args)
  end

  #SRIWW: Using the existing query to generate category-wise activity stream events for the Travel Market Showcase
  def self.find_by_category(sponsor_account_id,*args)
    ModelUtil.add_joins!(args,"left join profiles on profiles.id=profile_id left join attachments pp on pp.id=profiles.primary_photo_id")
    ModelUtil.add_joins!(args,"left join groups on groups.id=group_id left join attachments gp on gp.id=groups.primary_photo_id")
    ModelUtil.add_joins!(args,"left join questions on activity_stream_events.klass='Question' and questions.id=klass_id")
    ModelUtil.add_joins!(args,"left join answers on activity_stream_events.klass='Answer' and answers.id=klass_id")
    ModelUtil.add_joins!(args,"left join group_posts on activity_stream_events.klass='GroupPost' and group_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join blog_posts on activity_stream_events.klass='BlogPost' and blog_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.id=klass_id") 
    ModelUtil.add_joins!(args,"left join comments on activity_stream_events.klass='Comment' and comments.id=klass_id")
    ModelUtil.add_joins!(args,"left join statuses on activity_stream_events.klass='Status' and statuses.id=klass_id")
    ModelUtil.add_joins!(args,"left join profile_awards on activity_stream_events.klass='ProfileAward' and profile_awards.id=klass_id left join awards on profile_awards.award_id = awards.id")
    ModelUtil.add_joins!(args,"left join questions as answer_questions on activity_stream_events.klass='Answer' and answers.id=klass_id and answers.question_id=answer_questions.id")
    ModelUtil.add_joins!(args,"left join blog_posts as comment_blog_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'BlogPost' and comments.owner_id=comment_blog_posts.id")
    ModelUtil.add_joins!(args,"left join group_posts as comment_group_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'GroupPost' and comments.owner_id=comment_group_posts.id")
   ModelUtil.add_joins!(args,"left join questions as question_question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.owner_type='Group' and question_referrals.id=klass_id and question_referrals.question_id=question_question_referrals.id")


   ModelUtil.add_selects!(args,"activity_stream_events.*"+
    ", profiles.screen_name as profile_screen_name"+
    ", profiles.karma_points as profile_karma_points"+
    ", pp.filename as profile_photo_filename"+
    ", pp.id as profile_photo_id"+
    ", questions.question as question_question"+
    ", answers.answer as answer_answer"+
    ", answers.question_id as answer_question_id"+
    
    ", answer_questions.question as answer_question_question"+
    ", comment_blog_posts.title as comment_blog_post_title"+
    ", comment_group_posts.post as comment_group_post_post"+
    ", group_posts.post as group_post_post"+
    ", question_question_referrals.question as question_question_referral_question"+
    
    ", groups.name as group_name"+
    ", gp.filename as group_photo_filename"+
    ", gp.id as group_photo_id"+
    ", blog_posts.title as blog_post_title"+
    ", comments.text as comment_text"+

    ", statuses.body as status_body"+
    ", awards.title as award_title")
   
    
    ModelUtil.add_conditions!(args, ["(groups.sponsor_account_id= #{sponsor_account_id} AND activity_stream_events.profile_id IS NULL) OR
    (activity_stream_events.profile_id IS NOT NULL AND (groups.sponsor_account_id= #{sponsor_account_id} OR profiles.sponsor_account_id = #{sponsor_account_id}) AND
    profiles.visible=?)", true]) 																																																																																																																																																																																																																										
    options = ModelUtil.get_options!(args)
    options[:group] = 'activity_stream_events.klass, activity_stream_events.klass_id'
    options[:order] = 'created_at desc' unless options.member?(:order)
    args.shift if args.first.to_sym == :all
    Rails.logger.info "The final query is:" + args.to_s
    res=self.paginate(*args)
 end

 #SRIWW: Using the existing query to generate group-wise activity stream events for the Travel Market Showcase
  def self.find_by_group(group_id,*args)
    ModelUtil.add_joins!(args,"left join profiles on profiles.id=profile_id left join attachments pp on pp.id=profiles.primary_photo_id")
    ModelUtil.add_joins!(args,"left join groups on groups.id=group_id left join attachments gp on gp.id=groups.primary_photo_id")
    ModelUtil.add_joins!(args,"left join questions on activity_stream_events.klass='Question' and questions.id=klass_id")
    ModelUtil.add_joins!(args,"left join answers on activity_stream_events.klass='Answer' and answers.id=klass_id")
    ModelUtil.add_joins!(args,"left join group_posts on activity_stream_events.klass='GroupPost' and group_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join blog_posts on activity_stream_events.klass='BlogPost' and blog_posts.id=klass_id")
    ModelUtil.add_joins!(args,"left join question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.id=klass_id") 
    ModelUtil.add_joins!(args,"left join comments on activity_stream_events.klass='Comment' and comments.id=klass_id")
    ModelUtil.add_joins!(args,"left join booth_marketing_messages on activity_stream_events.klass='BoothMarketingMessage' and booth_marketing_messages.active=1 and booth_marketing_messages.id=klass_id")
    ModelUtil.add_joins!(args,"left join statuses on activity_stream_events.klass='Status' and statuses.id=klass_id")
    ModelUtil.add_joins!(args,"left join profile_awards on activity_stream_events.klass='ProfileAward' and profile_awards.id=klass_id left join awards on profile_awards.award_id = awards.id")
    ModelUtil.add_joins!(args,"left join questions as answer_questions on activity_stream_events.klass='Answer' and answers.id=klass_id and answers.question_id=answer_questions.id")
    ModelUtil.add_joins!(args,"left join blog_posts as comment_blog_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'BlogPost' and comments.owner_id=comment_blog_posts.id")
    ModelUtil.add_joins!(args,"left join group_posts as comment_group_posts on activity_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'GroupPost' and comments.owner_id=comment_group_posts.id")
   ModelUtil.add_joins!(args,"left join questions as question_question_referrals on activity_stream_events.klass='QuestionReferral' and question_referrals.owner_type='Group' and question_referrals.id=klass_id and question_referrals.question_id=question_question_referrals.id")


   ModelUtil.add_selects!(args,"activity_stream_events.*"+
    ", profiles.screen_name as profile_screen_name"+
    ", profiles.karma_points as profile_karma_points"+
    ", pp.filename as profile_photo_filename"+
    ", pp.id as profile_photo_id"+
    ", questions.question as question_question"+
    ", answers.answer as answer_answer"+
    ", answers.question_id as answer_question_id"+
    
    ", answer_questions.question as answer_question_question"+
    ", comment_blog_posts.title as comment_blog_post_title"+
    ", comment_group_posts.post as comment_group_post_post"+
    ", group_posts.post as group_post_post"+
    ", question_question_referrals.question as question_question_referral_question"+
    
    ", groups.name as group_name"+
    ", gp.filename as group_photo_filename"+
    ", gp.id as group_photo_id"+
    ", blog_posts.title as blog_post_title"+
    ", comments.text as comment_text"+
    ", statuses.body as status_body"+
    ", awards.title as award_title")
   
    ModelUtil.add_conditions!(args, ["(groups.id= #{group_id} AND activity_stream_events.profile_id IS NULL) OR (groups.id=#{group_id} AND activity_stream_events.profile_id IS NOT NULL AND profiles.visible=?)",true])
    options = ModelUtil.get_options!(args)
    options[:group] = 'activity_stream_events.klass, activity_stream_events.klass_id'
    options[:order] = 'created_at desc' unless options.member?(:order)
    args.shift if args.first.to_sym == :all
    res=self.paginate(*args)
 end

  def profile_karma_points
    self[:profile_karma_points].to_i
  end

  def primary_photo_path(which=:thumb)
    return Attachment.generate_photo_path(profile_photo_id,profile_photo_filename,which) if profile_photo_id
    return Attachment.generate_photo_path(group_photo_id,group_photo_filename,which) if group_photo_id
    nil
  end

  def self.add(klass,klass_id,action,opts)
    event = ActivityStreamEvent.new(opts.merge!(:klass => klass.to_s, :klass_id => klass_id, :action => (action.nil? ? nil : action.to_s)))
    event.save unless ActivityStreamEvent.last && ActivityStreamEvent.duplicates?(event, ActivityStreamEvent.last)
  end

  def event_object
    # return event_note if event_note
    Kernel.const_get(klass).find(klass_id)
  end

  class << self
    def cleanup_old_events(options={})
      if options[:max_id]
        cleanup_old_events_by_id options[:max_id]
      elsif options[:records_to_keep] && options[:earliest_date_to_keep]
        r_max_id = cleanup_max_id_by_count options[:records_to_keep]
        d_max_id = cleanup_max_id_by_datetime options[:earliest_date_to_keep]
        
        if d_max_id < r_max_id
          cleanup_old_events_by_id d_max_id
        else
          cleanup_old_events_by_id r_max_id
        end
      elsif options[:records_to_keep]
        cleanup_old_events_while_keeping options[:records_to_keep]
      elsif options[:earliest_date_to_keep]
        cleanup_old_events_since options[:earliest_date_to_keep]
      end
    end
    
    def cleanup_old_events_by_id(max_id)
      delete_all("id<#{max_id}")
    end
    
    def cleanup_old_events_while_keeping(records_to_keep)
      cleanup_old_events_by_id cleanup_max_id_by_count(records_to_keep)
    end

    def cleanup_old_events_since(earliest_date_to_keep)
      cleanup_old_events_by_id cleanup_max_id_by_datetime(earliest_date_to_keep)
    end
    
    def cleanup_max_id_by_count(records_to_keep)
      count_by_sql("select id from activity_stream_events order by created_at desc limit #{records_to_keep},1")
    end
    def cleanup_max_id_by_datetime(earliest_date_to_keep)
      count_by_sql("select id from activity_stream_events where created_at < '#{earliest_date_to_keep.strftime("%Y-%m-%d %H:%M:%S")}' order by created_at desc limit 1")
    end    
  end
  
  private
  
  def self.duplicates?(event_one, event_two)
    %w(klass klass_id profile_id action group_id).each do |prop|
      return false if event_one[prop] != event_two[prop]
    end
    true
  end

end
