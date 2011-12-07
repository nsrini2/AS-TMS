# lib/tasks/jobs_runner.rake

namespace :dj do
  desc "Manually kickoff the job_runner"
  task :run => :environment do
    puts "Running ..."
    begin        
      Delayed::Worker.new.work_off
    rescue
      Rails.logger.warn "Problem with working off DJs: #{$!}"
    end
  end

end