# lib/tasks/notify_chat_rsvp.rake

namespace :rss do
  desc "Pull RSS Feeds into blogs"
  task :pull => :environment do
    begin      
      RssFeed.pull_to_blogs
    rescue
      Rails.logger.error "Problem fetching RSS feeds: #{$!}"
    end
  end

end