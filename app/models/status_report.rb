class StatusReport
  @header = ["User Id", "User Email", "User Created At", "User Updated At", 
            "Profile Screen Name", "Profile Status",  
            "Profile Primary Photo", "Profile Karma Point", "Profile Last Accessed", "Profile Last Sent Welcome At"]
  @output_file = "data_dump_#{Time.now.to_i}"
  @time_tracking_file = "times"
  @mark = Time.now
  
  
class << self
  def weekly_dump
    data = "Number of Deals, #{Offer.approved.deals.count}\n" 
    data << "Number of Extras, #{Offer.approved.extras.count}\n\n"  
    
    admin_reporter = AdminController.new  
    karma_values = admin_reporter.send(:karma_summary_result).data
    question_values = admin_reporter.send(:questions_summary_result).data
    karma_values.each do |karma_value|
      data << "karma level #{karma_value.join(',')}\n"
    end  
    data << "\n"
    
    question_values.each do |question_value|
      data << "#{question_value.join(',')}\n"
    end
    data << "\n"
    
    weekly_visitor_count = SiteVisit.weekly_visitors
    weekly_visitor_count.each do |day_count|
      data << "Number of unique visitors on, #{day_count}\n"
    end
    data << "\n"
    
    weekly_visitor_count_by_countries = SiteVisit.weekly_visitors_by_country  
    weekly_visitor_count_by_countries.each do |visitor_count_by_countries|
      visitor_count_by_countries.each do |visitor_count_by_country|
        visitor_count_by_country.gsub!(/[\n\r]/, '')
        data << "Number of unique visitors on, #{visitor_count_by_country}\n"
      end
    end
    data << "\n"
    
    profile_count_by_countries = SiteVisit.active_profiles_by_country
    profile_count_by_countries.each do |profile_count_by_country|
      data << "Number of active profiles from, #{profile_count_by_country.country.gsub(/[\n\r]/, '')}, #{profile_count_by_country.profile_count}\n"
    end
    
    data
  end
  

  
  
  def data_dump
    # reset timer
    @mark = Time.now
    mark_time("Starting Report")
    # I would prefer to put a query in Profile that pulls all of this into a profile object
    profiles = Profile.all(:conditions => ["sataus = 1"] )
    
    profiles.each do |profile|
      user = profile.user
      user_details = []
    
      user_details << user.id
      user_details << user.email
      user_details << user.created_at
      user_details << user.updated_at
    
      user_details << profile.screen_name
      user_details << profile.status
      # user_details << profile.completion_percentage -- this is SLOW
      user_details << profile.primary_photo
      user_details << profile.karma_points
      user_details << profile.last_accessed
      user_details << profile.last_sent_welcome_at
    end  
    
    

    # File.open(result_file, 'w') {|f| f.write(results) }
  end 
  
  def mark_time(action="action")
    line = "#{(Time.now - @mark).to_i}  :  #{action}\n"
    line = "\n\n#{'=' * 100}\n#{line}" if action == "Starting Report"
    File.open(@time_tracking_file, 'a+') {|f| f.write(line) }
    @mark = Time.now
  end
  
  def sarah_report(filename)
    # See CustomReport.sarah_report
    report =  ["User Id", "User Email", "User Created At", "User Updated At", 
              "Profile Screen Name", "Profile Status", "Profile Completion Percentage",
              "Profile Primary Photo", "Profile Karma Point", "Profile Last Accessed", "Profile Last Sent Welcome At"]
    
    User.find(:all, :include => [:profile => [:site_registration_fields]]).each do |user|      
      # Skip wierd users without profiles
      next unless user.profile
      
      user_details = []
      
      user_details << user.id
      user_details << user.email
      user_details << user.created_at
      user_details << user.updated_at
      
      profile = user.profile
      
      user_details << profile.screen_name
      user_details << profile.status
      user_details << profile.completion_percentage
      user_details << profile.primary_photo
      user_details << profile.karma_points
      user_details << profile.last_accessed
      user_details << profile.last_sent_welcome_at
      
      SiteRegistrationField.all.each do |reg_field|        
        if report.size == 1
          report.first << reg_field.label # Put in header info
        end
        
        field = profile.profile_registration_fields.detect{ |prf| prf.site_registration_field == reg_field }
        
        user_details << (field ? field.value : nil)
      end
      
      report
      
      Profile.profile_complex_questions.each_pair do |column_name, question|
        if report.size == 1
          report.first << question.label # Put in header info
        end
        
        user_details << profile[column_name]
      end
      
      report << user_details
    end
    
    FasterCSV.open(filename, "w") do |csv|
      report.each do |r|
        csv << r
      end
    end
    
    File.read(filename)
  end
end  
  
end  