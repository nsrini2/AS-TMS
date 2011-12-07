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

end