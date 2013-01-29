# Tasks specific to running cubeless as a rails engine
namespace :live_qa_engine do
  desc "Sync files from live_qa engine."
  task :sync_migrations do
    # also had to remove crate_posts migrations, cause it was there...  May want to call these chat posts?
    system "rsync -ruv --exclude=.svn vendor/plugins/live_qa/db/migrate db"
    # system "rsync -ruv --exclude=.svn vendor/plugins/live_qa/public ."
  end
  
  task :sync_public do
    # system "rsync -ruv --exclude=.svn vendor/plugins/live_qa/public ."
  end  
  
  task :sync_js do
    
  end  
end