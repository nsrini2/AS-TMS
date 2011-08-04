class StatusReport
  @header = ["User Id", "User Email", "User Created At", "User Updated At", 
            "Profile Screen Name", "Profile Status",  
            "Profile Primary Photo", "Profile Karma Point", "Profile Last Accessed", "Profile Last Sent Welcome At"]
  @output_file = "data_dump_#{Time.now.to_i}"
  @time_tracking_file = "times"
  @mark = Time.now
  
  
class << self
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