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
end