# lib/tasks/notify_chat_rsvp.rake

namespace :notify do
  desc "Send reminder emails to people who RSVPed to Live Chat"
  task :chat_rsvp => :environment do
    puts "Running ..."
    begin
      STDERR.puts "Sending chat reminder emails."       
      Chat.send_rsvp_emails
    rescue
      STDERR.puts "Problem sending chat reminder emails: #{$!}"
      Rails.logger.error "Problem sending chat reminder emails: #{$!}"
    end
  end

end