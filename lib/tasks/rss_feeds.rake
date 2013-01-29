# lib/tasks/notify_chat_rsvp.rake

namespace :rss do
  desc "Pull RSS Feeds into blogs"
  task :pull => :environment do
    begin      
      RssFeed.pull_to_blogs
    rescue
      STDERR.puts "Problem fetching RSS feeds: #{$!}"
      Rails.logger.error "Problem fetching RSS feeds: #{$!}"
    end
  end

end