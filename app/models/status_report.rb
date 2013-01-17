class Numeric
  def percent_of(n)
    (self.to_f / n.to_f * 100.0).round(2).to_i.to_s + "%"
    rescue FloatDomainError
      "0%"
  end
end

class StatusReport
  @header = ["User Id", "User Email", "User Created At", "User Updated At", 
            "Profile Screen Name", "Profile Status",  
            "Profile Primary Photo", "Profile Karma Point", "Profile Last Accessed", "Profile Last Sent Welcome At"]
  @output_file = "data_dump_#{Time.now.to_i}"
  @time_tracking_file = "times"
  @mark = Time.now
  
  
class << self
  def mail_news_post_views
    Notifier.news_post_views(News.post_views).deliver
  end
  
  def mail_monthly_activity_report
    data = monthly_activity_report
    # SSJ 2012-09-04 speed up query, so this should no longer be necessary
    Notifier.monthly_activity_report(data)
  end
  
  def monthly_activity_report
    # This report should be run on the first day of the month and capture the previous months stats
    today = Date.today
    first_day_of_month = today.advance(:months => -1).at_beginning_of_month
    last_day_of_month = first_day_of_month.at_end_of_month
    
    data = "Number of Deals, #{Offer.approved.deals.count}\n" 
    data << "Number of Extras, #{Offer.approved.extras.count}\n\n"  
    
    # Community Karma Levels
    admin_reporter = AdminController.new  
    karma_values = admin_reporter.send(:karma_summary_result).data
    karma_values.each do |karma_value|
      data << "#{karma_value.join(',')}\n"
    end  
    data << "\n"
    
    # Top 10 Karma earners this month
    top_monthly_contributors = KarmaHistory.top_ten_karma_earners_for_month(first_day_of_month)
    top_monthly_contributors.each do |c|
      data << "\"#{c.screen_name}\",\"#{c.agency_name}\",\"#{c.agency_type}\",#{c.karma_earned}\n"
    end  
    data << "\n"
    
    # Question Details
    question_values = admin_reporter.send(:questions_summary_result).data
    question_values.each do |question_value|
      data << "#{question_value.join(',')}\n"
    end
    data << "\n"
    
    # Answers
    data << "Total Answers,#{Answer.count}\n\n"
    
    
    # Number of unique visitors by month
    data << "Month of:,Unique logins\n"
    start_date = today.advance(:months => -1)
    data << "#{start_date.strftime('%B')}, #{SiteVisit.visitors_by_month(start_date)}\n\n"  
    
    # Number of unique visitors by week
    data << "Week of:,Unique logins, Total Community Size\n"
    (1..52).each do |week|
      start_date = (today - week.weeks).beginning_of_week
      data << "#{start_date}, #{SiteVisit.visitors_by_week(start_date)}, #{SiteStatHistory.stat_by_week('active_members', start_date)}\n"
    end  
    data << "\n"
    
    # Top ten countries with most visitors by week for the given month
    top_visitor_countries = SiteVisit.visitors_by_country(first_day_of_month, last_day_of_month)
    top_visitor_countries.each do | visit |
      data << "Number of unique visitors from, #{visit.country.chomp}, #{visit.profile_count}\n"
    end
    
    #agency booking type
    data << "\n"
    booking_types = percent_agency_booking_type
    ["Leisure", "Corporate", "Generalist", "Other"].each do |type|
      data << "#{type}, #{percent_agency_booking_type[type]}\n"
    end  
    data << "\n"
    
    data
  end
  
  def percent_agency_booking_type
    total = Profile.where("profiles.profile_8 IS NOT NULL").count.to_f
    leisure = Profile.where("profile_8 LIKE ? ", "%leisure%").where("profile_8 NOT LIKE ? ", "%corporate%").count
    corporate = Profile.where("profile_8 LIKE ? ", "%corporate%").where("profile_8 NOT LIKE ? ", "%leisure%").count
    generalist = Profile.where("profile_8 LIKE ? ", "%generalist%").count
    other = total - leisure - corporate - generalist
    {"Leisure" => leisure.percent_of(total), "Corporate" => corporate.percent_of(total), "Generalist" => generalist.percent_of(total), "Other" => other.percent_of(total) }
  end
  
  def mail_users_by_country_report
    data = StatusReport.users_by_country
    Notifier.users_by_country_report(data).deliver
  end
  
  def users_by_country
    SiteVisit.active_profiles_by_country.map do |profile_count_by_country|
       "Number of active profiles from, #{profile_count_by_country.country.gsub(/[\n\r]/, '')}, #{profile_count_by_country.profile_count}\n"
    end
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