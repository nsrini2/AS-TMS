module ActivityStreamInterface
  def self.included(base)
    base.send :include, Rails.application.routes.url_helpers
    base.send :include, ActionView::Helpers::TextHelper
    base.send :include, ActionView::Helpers::DateHelper
    base.default_url_options[:host]= 'www.agentstream.com'
  end
  
  ####  PRESENTER METHODS -- perhaps put in ActivityStreamInterface module ??? ####
  def reference
    #SSJ 2/16/2012 -- I would like to put all of this in the classes the events reference, but this allows us to move them one at a time
    case klass
    when /Topic/ 
      klass.constantize.find(klass_id)
    else
      self
    end    
  end
  
  
  def owner_path
   group_id ? url_for(group_path(:id => self.group_id)) : self.profile ? url_for(profile_path(self.profile)) : ""
  end

  def event_path
    # SSJ want to try setting @event to the event.klass then calling path on it?

    # SRIWW:04/17/13 - Changing this method to include all possible activity stream events
    #if group_id && !profile_id
      #url_for(group_path(:id => group_id))
    #else
      case klass
        when "Answer": "/questions/#{Answer.find_by_id(klass_id).question_id}"
        when "Question": "/questions/#{klass_id}"
        when "GroupMembership": url_for(group_path(:id => group_id))
        when "BlogPost": "/blog_posts/#{klass_id}"
        when "Comment": "/comments/#{klass_id}"
        when "QuestionReferral": "/questions/#{(QuestionReferral.find_by_id(klass_id)).question_id}"
        when "Group": url_for(group_path(:id => group_id))
        when "GroupPhoto" : url_for(group_path(:id => group_id))
        when "GroupPost": "/groups/#{group_id}/group_posts/#{klass_id}"
        when "ProfileAward": "/profiles/#{profile_id}"
        when "GalleryPhoto": "/groups/#{group_id}/gallery_photos/#{klass_id}"
      #   if event_object.owner.respond_to?(:news?) && event_object.owner.news? #Exception for news post
      #     news_post_path(event_object.owner) + "#comments"
      #   else    
      #     polymorphic_path(event_object.owner) + "#comments"
      #   end 
        else self.profile ? url_for(profile_path(self.profile)) : ""
      end
    #end  
  end

  def icon_path
   event_icon_path = "/images/icons/as"
   event_icon_path << case klass
                       when "Status": "/comment.png"
                       when /(Question|Answer|QuestionReferral)/: "/help.png"
                       when /(GroupPost|Blog)/: "/write-note.png"
                       when /Comment/: "/comment.png"
                       when /ProfileAward/: "/trophy.png"
                       when /(Profile|ProfilePhoto)/: "/user.png"
                       when /Ad/: "/ticket.png"
                       when /(Group|GroupMembership|GroupPhoto|GalleryPhoto)/: "/user-group.png"
                    end
  end


  def who
   if group_id && !profile_id
     group_name
   elsif respond_to?(:profile_screen_name)
     profile_screen_name
   elsif respond_to?(:profile) && profile
     profile.screen_name    
   else
     ""
   end
  end

  def what
   text = []
   if group_id && !profile_id
     text << group_event_verb_text()
     text << group_event_what_text()
   else
     text << profile_event_what_text()
   end

   text.join(" ")
  end

  def profile_event_what_text
   text = []
   case klass
     when 'Profile': 
       text << "updated profile details"
       text << "<br />"
     when 'ProfilePhoto': 
       text << "updated profile photo"
       #text << "<span>[\"#{truncate(self.profile_photo_filename, { :length => 20, :omission => "..." })}\"]</span>"
       text << "<br />"
     when 'Answer': 
       text << "answered the question:"
       text << "<br />"
       text << "<em>\"#{truncate(self.answer_question_question, { :length => 100, :omission => "..." })}\"</em><br />"
       text << "<span>\"#{truncate(self[:answer_answer], { :length => 100, :omission => "..." })}\"</span>"
     when 'Question': 
       #text << "asked a question:"
       text << "<span>"
       text << truncate(self[:question_question], { :length => 100, :omission => "..." })
       text << "</span>"
     when 'Login': 
       text << "logged in"
       text << "<br />"
     when 'GroupMembership': 
       text << "joined the group:<br /><span> " + truncate(self.group_name, { :length => 100, :omission => "..." })
       text << "</span>"
     when 'BlogPost': 
       text << "added a blog post:"
       text << "<br /><span>"
       text << truncate(self.blog_post_title, { :length => 100, :omission => "..." })
       text << "</span>"
     when 'Comment':
       text << "added a comment:" 
       text << "<br /><span>"
       text << truncate(self.comment_text, { :length => 100, :omission => "..." })
       text << "</span><br />"
       if self.comment_blog_post_title
         text << "<em>[comment on the Blog Post - \"#{truncate(self.comment_blog_post_title, { :length => 40, :omission => "..." })}\"]</em>"
       elsif self.comment_group_post_post
         text << "<em>[comment on the Group Post - \"#{truncate(self.comment_group_post_post, { :length => 100, :omission => "..." })}\"]</em>"
       end
     when 'ProfileAward': 
       text << "received an award:"
       text << "<br />"
       text << "was awarded the <span>'" + truncate(self.award_title, { :length => 100, :omission => "..." }) + "'</span>"
     when 'Status': 
       text << "shared an update:"
       text << "<br /><span>"
       text << self.status_body
       text << "</span>"
     when 'GroupPost':
       text << "added a group post:"
       text << "<br /><span>"
       text << truncate(self.group_post_post, { :length => 100, :omission => "..." })
       text << "</span>"
     when 'GalleryPhoto':
       text << "added a gallery photo to the booth:'"
       text << group_name + "'"
   end

  text.join(" ")
  end

  def group_event_verb_text
   case klass
      when 'Group': "was"
      when 'GroupPhoto': "updated"
      else "was"
   end
  end

  def group_event_what_text
   text=[]
   case klass
      when 'Group': "#{self.action}d"
      when 'GroupPhoto'
           text << "their group photo"
           #text << "<span>\"#{truncate(self.group_photo_filename, { :length => 20, :omission => "..." })}\"</span>"
      when 'QuestionReferral'
           text << "referred a question:"
           text << "<br/>"
           text << "<span>\"#{truncate(self.question_question_referral_question, { :length => 100, :omission => "..." })}\"</span>"
      else "#{self.action}d"
   end    
  end

  def when
    "#{time_ago_in_words(created_at)} ago"
  end 
end 
