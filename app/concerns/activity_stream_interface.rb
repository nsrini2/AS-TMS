module ActivityStreamInterface
  def self.included(base)
    base.send :include, Rails.application.routes.url_helpers
    base.send :include, ActionView::Helpers::TextHelper
    base.send :include, ActionView::Helpers::DateHelper
    base.default_url_options[:host]= 'www.agentstream.com'
  end
  
  ####  PRESENTER METHODS -- perhaps put in ActivityStreamInterface module ??? ####
  def owner_path
   group_id ? url_for(group_path(:id => self.group_id)) : self.profile ? url_for(profile_path(self.profile)) : ""
  end

  def event_path
   # SSJ want to try setting @event to the event.klass then calling path on it?
   if group_id && !profile_id
     url_for(group_path(:id => group_id))
   else
     case klass
       when "Answer": "/questions/#{Answer.find_by_id(klass_id).question_id}"
       when "Question": "/questions/#{klass_id}"
       when "GroupMembership": url_for(group_path(:id => group_id))
       when "BlogPost": "/blog_posts/#{klass_id}"
       when "Comment": "/comments/#{klass_id}"
       else
         self.profile ? url_for(profile_path(self.profile)) : ""
     end
   end  
  end

  def icon_path
   event_icon_path = "/images/icons/as"
   event_icon_path << case klass
                       when /Group/: "/user-group.png"
                       when "Status": "/comment.png"
                       when /(Question|Answer)/: "/help.png"
                       when /(Blog|Comment)/: "/write-note.png"
                       when /Profile/: "/user.png"
                       when /Ad/: "/ticket.png"
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
     when 'ProfilePhoto': 
    	  text << "updated profile photo"
     when 'Answer': 
    	  # text << "answered a question:"
    	  text << truncate(self[:answer_answer], { :length => 100, :omission => "..." })
    	  text << "<br/><span>[answer to \"#{truncate(self.answer_question_question, { :length => 60, :omission => "..." })}\"]</span>"
     when 'Question': 
    	  # text << "asked a question:"
    	  text << truncate(self[:question_question], { :length => 100, :omission => "..." })
     when 'Login': 
    	  text << "logged in"
     when 'GroupMembership': 
    	  # text << "joined a group:"
    	  text << "joined the group: " + truncate(self.group_name, { :length => 100, :omission => "..." })
     when 'BlogPost': 
    	  # text << "added a blog post:"
    	  text << truncate(self.blog_post_title, { :length => 100, :omission => "..." })
     when 'Comment': 
    	  text << truncate(self.comment_text, { :length => 100, :omission => "..." })
    	  text << "<br/><span>[comment on \"#{truncate(self.comment_blog_post_title, { :length => 60, :omission => "..." })}\"]</span>"
     when 'ProfileAward': 
    	  # text << "received an award:"
    	  text << "was awwarded the " + truncate(self.award_title, { :length => 100, :omission => "..." })
     when 'Status': 
    	  # text << "shared an update:"
    	  text << self.status_body 	
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
   case klass
      when 'Group': "#{self.action}d"
  	  when 'GroupPhoto': "group photo"
     else "#{self.action}d"
   end    
  end

  def when
    "#{time_ago_in_words(created_at)} ago"
  end 
end 