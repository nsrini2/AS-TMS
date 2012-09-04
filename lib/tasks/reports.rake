# lib/tasks/reports.rake

namespace :reports do
  desc "Manually kickoff the data_dump, AKA sarah_report"
  task :data_dump => :environment do
    puts "Running ..."
    name = Time.now.strftime("data_dump_%m_%d_%Y.csv")
    begin        
      CustomReport.sarah_report(name)
    rescue
      Rails.logger.warn "Problem with running data_dump: #{$!}"
    end
  end
  
  desc "email the weekly_report"
  task :send_weekly_report => :environment do
    puts "Running ..."
    begin        
      StatusReport.mail_weekly_report
    rescue
      puts "Problem with running weekly_report: #{$!}"
      Rails.logger.warn "Problem with running weekly_report: #{$!}"
    end
  end
  
  
  desc "email the monthly_activity_report"
  task :send_monthly_activity_report => [:capture_karma_points] do
    puts "Sending Monthly Activity Report"
    begin        
      StatusReport.mail_monthly_activity_report
    rescue
      puts "Problem with running monthly_activity_report: #{$!}"
      Rails.logger.warn "Problem with running monthly_activity_report: #{$!}"
    end
  end
  
  desc "email the active_users_by_country_report"
  task :send_active_users_by_country_report => :environment do
    puts "Sending Active Users By Country Report"
    begin        
      StatusReport.mail_users_by_country_report
    rescue
      puts "Problem with running active_users_by_country_report: #{$!}"
      Rails.logger.warn "Problem with running active_users_by_country_report: #{$!}"
    end
  end
  
  desc "update karma earned"
  task :capture_karma_points => :environment do
    puts "Capturing karma points"
    begin        
      KarmaHistory.capture_points
    rescue
      puts "Problem with updated Karma history: #{$!}"
      Rails.logger.warn "Problem updating karma history: #{$!}"
    end
  end
  
  desc "email ALL monthly reports"
  task :send_monthly_reports => [:send_monthly_activity_report, :send_active_users_by_country_report] do
    puts "Sending all monthly reports"
  end
  
end