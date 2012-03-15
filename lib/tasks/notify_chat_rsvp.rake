# lib/tasks/notify_chat_rsvp.rake

namespace :notify do
  desc "Send reminder emails to people who RSVPed to Live Chat"
  task :chat_rsvp => :environment do
    puts "Running ..."
    log_file_path = (`pwd`).chomp + "/log/rake_notify.log"
    log_file = File.open(log_file_path, 'a')
    log_file << "Running rake:chat_rsvp.\n#{Time.now}::Next Chat starts at: #{Chat.next.start_at} which is in #{((Chat.next.start_at - Time.now).floor / 60)} minutes\n"  
    begin     
      Chat.send_rsvp_emails
    rescue
      log_file << "Problem sending chat reminder emails: #{$!}\n"
      Rails.logger.error "Problem sending chat reminder emails: #{$!}"
    ensure
      log_file.close
    end
  end

end