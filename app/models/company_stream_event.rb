class CompanyStreamEvent < ActiveRecord::Base
  belongs_to :profile
  
  validates_numericality_of :company_id, :greater_than => 0
  
  self.per_page = 10
  
  def primary_photo_path(which=:thumb)
    return Attachment.generate_photo_path(profile_photo_id,profile_photo_filename,which) if profile_photo_id
    return Attachment.generate_photo_path(group_photo_id,group_photo_filename,which) if group_photo_id
    nil
  end


  class << self
    # MM2: I'm truly sorry for adding to this mess and not fixing it. (2010-07-20 - status additions)
    def find_summary(*args)
      ModelUtil.add_joins!(args,"left join profiles on profiles.id=profile_id left join attachments pp on pp.id=profiles.primary_photo_id")
      ModelUtil.add_joins!(args,"left join groups on groups.id=group_id left join attachments gp on gp.id=groups.primary_photo_id")
      ModelUtil.add_joins!(args,"left join questions on company_stream_events.klass='Question' and questions.id=klass_id")
      ModelUtil.add_joins!(args,"left join answers on company_stream_events.klass='Answer' and answers.id=klass_id")
      ModelUtil.add_joins!(args,"left join blog_posts on company_stream_events.klass='BlogPost' and blog_posts.id=klass_id")
      ModelUtil.add_joins!(args,"left join comments on company_stream_events.klass='Comment' and comments.id=klass_id")
      ModelUtil.add_joins!(args,"left join statuses on company_stream_events.klass='Status' and statuses.id=klass_id")
      ModelUtil.add_joins!(args,"left join profile_awards on company_stream_events.klass='ProfileAward' and profile_awards.id=klass_id left join awards on profile_awards.award_id = awards.id")
      
      # MM2: More adding :( (2010-11-08)
      ModelUtil.add_joins!(args,"left join questions as answer_questions on company_stream_events.klass='Answer' and answers.id=klass_id and answers.question_id=answer_questions.id")
      ModelUtil.add_joins!(args,"left join blog_posts as comment_blog_posts on company_stream_events.klass='Comment' and comments.id=klass_id and comments.owner_type = 'BlogPost' and comments.owner_id=comment_blog_posts.id")
          
      
      ModelUtil.add_selects!(args,"company_stream_events.*"+
      ", profiles.screen_name as profile_screen_name"+
      ", profiles.karma_points as profile_karma_points"+
      ", pp.filename as profile_photo_filename"+
      ", pp.id as profile_photo_id"+
      ", questions.question as question_question"+
      ", answers.answer as answer_answer"+
      ", answers.question_id as answer_question_id"+
      
      ", answer_questions.question as answer_question_question"+
      ", comment_blog_posts.title as comment_blog_post_title"+
      
      ", groups.name as group_name"+
      ", gp.filename as group_photo_filename"+
      ", gp.id as group_photo_id"+
      ", blog_posts.title as blog_post_title"+
      ", comments.text as comment_text"+
      ", statuses.body as status_body"+
      ", awards.title as award_title")


      # Do not display GroupMemberships of invisible people
      # I know...that sounds whack...but it has happened...
      ModelUtil.add_conditions!(args, ["(company_stream_events.profile_id IS NULL OR (company_stream_events.profile_id IS NOT NULL AND profiles.visible = ?))", true])

      options = ModelUtil.get_options!(args)
      options[:order] = 'created_at desc'
      args.shift if args.first.to_sym == :all
      self.paginate(*args)
    end
    

    
    def add(klass,klass_id,action, company_id, opts={})
      event = CompanyStreamEvent.new(opts.merge!(:klass => klass.to_s, :klass_id => klass_id, :action => (action.nil? ? nil : action.to_s), :company_id => company_id))
      event.save unless CompanyStreamEvent.last && CompanyStreamEvent.duplicates?(event, CompanyStreamEvent.last)
    end 
    
    def duplicates?(event_one, event_two)
      %w(klass klass_id profile_id action group_id).each do |prop|
        return false if event_one[prop] != event_two[prop]
      end
      true
    end
  end
end
