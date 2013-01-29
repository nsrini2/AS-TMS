# Tasks specific to running cubeless as a rails engine
namespace :cubeless_engine do
  desc "Sync extra files from cubeless engine."
  task :sync do
    system "rsync -ruv --exclude=.svn vendor/plugins/cubeless/db/migrate db"
    system "rsync -ruv --exclude=.svn vendor/plugins/cubeless/public ."
  end
end

namespace :jobs do
  namespace :custom do
    desc "Send email that Delayed jobs are failing"
    task :alert => [:environment] do
      active_jobs = Delayed::Job.find(:all, :conditions => ['locked_at IS NOT NULL AND locked_at < ? ', Time.now - 2.hours ])
      if active_jobs.count > 0 then
        site_name = Config[:site_name]
        recipients = ["scott.johnson@sabre.com", "mark.mcspadden@sabre.com"]
        subject = "A Delayed Job did not finish..."
        body  = "#{Config[:site_name]} has #{active_jobs.count} delayed job(s) that are more than 2 hours old.  Please investigate."
        Notifier.deliver_generic_email(subject, body, recipients)
        # puts "**********\n  #{body}\n**********"
      end  
    end

  end  
end