Delayed::Worker.guess_backend

# require 'rest_client'
require 'spawn'
require 'delayed_job'

module DelayedJobExtensions
  # SSJ 11-30-2010  Change delayed job to only attempt a job once
  # Because Delayed Job's built in error catching relies on updating the database
  # it fails if connectivity with the database is lost 
  # -- this sets default behavior to not retry a job that has been started
  module ClassMethods 
    def override_ready_to_run_named_scope
      named_scope :ready_to_run, lambda { |worker_name, max_run_time|
         { :conditions => ['(run_at <= ? AND locked_at IS NULL) AND failed_at IS NULL', db_time_now ] }
      }
    end
  end
  
  # Use the after commit plugin to prevent our race condition
  def after_commit_on_create
    # Instead of using an external manager, for now we're going to fork the process using the Spawn plugin
    # post_to_dj_central
    spawn do
      begin        
        Delayed::Worker.new.work_off
      rescue
        Rails.logger.warn "Problem with working off DJs: #{$!}"
      end
    end
  end

  def post_to_dj_central
    if Config[:dj_central_url]
      begin
        response = RestClient.post( Config[:dj_central_url], 
                                    { 'job' => { 'rails_root' => Rails.root } }.to_json, 
                                    :content_type => :json,
                                    :accept => :json)

        if response && response.to_s[/error/]
          Rails.logger.warn "Error with notifiying the Delayed Job Manager of a new job: #{response.to_s}"
          raise response.to_s
        end 
      rescue
        Rails.logger.warn "Error with notifiying the Delayed Job Manager of a new job: #{$!}"
        raise "Email Processing Error. Please contact support@cubeless.com."
      end
    end
  end
  
end

Delayed::Job.send :include, DelayedJobExtensions # instance methods
Delayed::Job.send :extend, DelayedJobExtensions::ClassMethods  # class methods
Delayed::Job.send :override_ready_to_run_named_scope
Delayed::Job.send :xss_terminate, :except => [:handler, :last_error] 

# SSJ 10-17-2011
# for some reason including a module (like above did not work here)
class Delayed::PerformableMailer
  def perform
    mail = object.send(method_name, *args)
    puts mail.class
    mail.deliver if mail.is_a?(Mail::Message)
  end
end  
 