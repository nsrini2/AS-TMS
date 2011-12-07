class RegistrationReportColumn < Struct.new(:month, :dates, :total_requests, :total_unique_requests, 
                                :total_unique_requests_not_active, :total_approved, :unique_approved, 
                                :unique_approved_active, :unique_approved_not_active, :unique_conversion_rate,
                                :errors, :new_questions, :new_answers)
                                
  def set_conversion_rate
    if self.unique_approved_active == 0 
      self.unique_conversion_rate = 'N/A'
    else   
      rate = self.unique_approved_active.to_f/self.unique_approved.to_f
      rate = sprintf( "%0.02f", rate*100)
      self.unique_conversion_rate = "#{(rate)}%"
    end  
  end
  
  def to_csv
    csv = ""
    self.members.each do | member |
      if !self.send(member).blank?
        csv << "#{member.humanize},"  #gsub(/_/, " ").capitalize},"
        csv << self.send(member).to_csv # calling to_csv on array
      end   
    end
    csv.chomp
  end
  
end

class CustomReport < ActiveRecord::Base
  # TODO: strip out the authenticity token piece of the form
                                                                         
  def self.agent_stream_usage_report()
    column_data = registration_data(:year)
    row_data = RegistrationReportColumn.new()
    # SSJ converting column data into row data
    # create a struc (same as column data) with arrays for values
    
    # set value of each member to an array with header as first entry
    row_data.members.each do |m|  
      row_data.send("#{m}=", []) 
    end
    
    # loop through each column struct and put values into row struct array
    column_data.each_with_index do | column, i |
      column.set_conversion_rate
      row_data.members.each do |m|
        unless m.to_sym == :dates 
          # row_data.send(m).send("[]=".to_sym, i, column.send(m) ) # same as below
          row_data.send(m)[i] = column.send(m)
        end  
      end  
    end
    # convert struct to csv
    csv = row_data.to_csv
  end
  
  def self.registration_data(time)
    time_frame = time.to_s
    valid= ['current', 'previous', 'year']
    unless valid.include? time_frame
      return "Please enter a valid time frame: #{valid.join(',')}"
    end  

    case time_frame
    when /current/i
      column = get_report_dates(0)
      column = add_monthly_registration_data(column)
      columns = [add_monthly_content_data(column)]
    when /previous/i
      column = get_report_dates(1)
      column = add_monthly_registration_data(column)
      columns = [add_monthly_content_data(column)]
    else #year
      columns= []
      (0..12).each do |offset|
        column = get_report_dates(offset)
        column = add_monthly_registration_data(column)
        columns << add_monthly_content_data(column)
      end
      columns.reverse!
    end 
    column = get_report_dates()
    # add 12 month total to end
    column = add_monthly_registration_data(column)
    columns << add_monthly_content_data(column)
  end

  def self.get_report_dates(time_frame=-1)
    d = Time.now().to_date
    if (0..12).include? time_frame.to_i
      d = d.months_ago(time_frame.to_i)
      start_date = d.beginning_of_month  
      end_date = d.end_of_month + 1
      month = Date::ABBR_MONTHNAMES[start_date.month]
    else # get last 12 months totals  
      month = '13 Month Total' 
      end_date = d.end_of_month + 1 
      d = d.years_ago(1)
      start_date = d.beginning_of_month
    end
    column = RegistrationReportColumn.new(month, " '#{start_date}' AND '#{end_date}' ")      
  end
  
  def self.add_monthly_registration_data(column)
    total_requests = User.total_requests(column.dates).count
    total_unique_requests = User.total_unique_requests(column.dates).count
    unique_requests_not_active = User.unique_requests_not_active(column.dates).count
    total_approved = User.total_users_approved(column.dates).count
    unique_approved = User.unique_users_approved(column.dates).count
    unique_approved_active = User.unique_approved_active(column.dates).count
    unique_approved_not_active = User.unique_approved_not_active(column.dates).count
    errors = ''
    if unique_approved_not_active + unique_approved_active != unique_approved
      errors = "Unique users !="
    end 
    if unique_approved_active + unique_requests_not_active != total_unique_requests 
      errors += "Total unique requests !="
    end
    column.total_requests = total_requests
    column.total_unique_requests = total_unique_requests
    column.total_unique_requests_not_active = unique_requests_not_active
    column.total_approved = total_approved
    column.unique_approved = unique_approved
    column.unique_approved_active = unique_approved_active
    column.unique_approved_not_active = unique_approved_not_active                                 
    column.errors = errors unless errors.blank?
    column                                                                                                                   
  end
  
  def self.add_monthly_content_data(column)                                                                                                                  
    column.new_questions = Question.find(:all, :conditions => "created_at BETWEEN #{column.dates}").count
    column.new_answers = Answer.find(:all, :conditions => "created_at BETWEEN #{column.dates}").count
    column
  end

  def self.sarah_report(filename)
    puts "Starting Report..."
    
    report = []
    
    report << ["User Id", "User Email", "User Created At", "User Updated At", 
              "Profile Screen Name", "Profile Status", "Profile Completion Percentage", 
              "Profile Primary Photo", "Profile Karma Point", "Profile Last Accessed", "Profile Last Sent Welcome At"]
    
    site_registration_fields = SiteRegistrationField.all
    biz_card_questions = Profile.profile_biz_card_questions
    complex_questions = Profile.profile_complex_questions
    
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
      
      site_registration_fields.each do |reg_field|        
        if report.size == 1
          report.first << reg_field.label # Put in header info
        end
        
        field = profile.profile_registration_fields.detect{ |prf| prf.site_registration_field == reg_field }
        
        user_details << (field ? field.value : nil)
      end

      biz_card_questions.each_pair do |column_name, question|
        if report.size == 1
          report.first << question.label # Put in header info
        end
      
        user_details << profile[column_name]
      end
      
      complex_questions.each_pair do |column_name, question|
        if report.size == 1
          report.first << question.label # Put in header info
        end
        
        user_details << profile[column_name]
      end
      
      report << user_details
    end
    
    puts "Writing CSV"
    
    FasterCSV.open(filename, "w") do |csv|
      report.each do |r|
        csv << r
      end
    end
    
    puts "Finishing"
    
    File.read(filename)
  end
end
