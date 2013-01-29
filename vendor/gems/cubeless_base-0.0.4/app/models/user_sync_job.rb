require 'yaml'
class UserSyncJob < ActiveRecord::Base
  
  xss_terminate :disable => true
  
  def self.instance
    self.first || self.new
  end

  def backup!
    now = Time.now
    
    # Detect or create RAILS_ROOT/db/sync_users_backups
    dir = "#{RAILS_ROOT}/db/sync_users_backups"
    File.makedirs(dir) unless File.exists?(dir)
    
    # Do an export
    file_name = "#{now.strftime("%s")}.csv"
    file_path = "#{dir}/#{file_name}"
    
    user_sync = UserSync.new
    user_sync.export_csv(file_path)
    
    # Compress the export
    system("cd #{dir} && tar -zcf #{file_name}.tar.gz #{file_name}")
    
    # Remove the original
    File.delete(file_path)
    
    clean_up_archives!(dir)
  end
  
  def clean_up_archives!(dir)
    now = Time.now
    
    # Clean up exports older than 30 days old if there are more than 5 backups
    # I know we said '5', but the Dir.entries returns '.' and '..'
    if Dir.entries(dir).size > 7
      Dir.entries(dir).each do |name|
        if name != "." && name != ".."
          seconds = name.split(".").first.to_i
          if seconds < (now.strftime("%s").to_i - (60*60*24*30))
            Rails.logger.warn "Removing User Sync Archive: #{name}"
            File.delete("#{dir}/#{name}")
          end
        end
      end  
    end
  end

  def start!
    if self.options[:commit] && self.options[:action] == "sync"
      backup!
    end
    
    update_attributes!(:status => 'running')    
  end
  
  def queue!(options)
    data = options.delete(:data)
    update_attributes!(:data => data, :options => options, :status => 'queued', :log_output => nil, :response_hash => nil, :response_message => nil, :start_time => Time.now)
  end
  
  def stop!    
    update_attributes!(:status => nil, :data => nil, :end_time => Time.now)
    
    # Send email alert on 'failed' or 'failures' with sync if it's not a test run
    if self.options[:commit] && self.options[:action] == "sync" && self.response_message =~ /fail/ 
      Notifier.deliver_failed_sync_users(self)
    end
  end
  
  def clear_results!
    update_attributes!(:response_message => nil, :response_hash => nil, :log_output => nil)
  end
  
  def stopped?
    status.nil?
  end
  
  def response_hash
    @reponse_hash ||= YAML.load(super || {}.to_yaml)
  end
  
  def response_hash=(h)
    @reponse_hash = nil
    super(h.to_yaml)
  end
  
  def options
    @options ||= YAML.load(super || {}.to_yaml)
  end
  
  def options=(h)
    @options = nil
    super(h.to_yaml)
  end
  
  def run
    
    raise "Job is already #{self.status || 'finished'}." unless self.status=='queued'
    self.start!

    action = self.options[:action]

    begin
      Tempfile.open('usersync') do |io|
        # use log_output as target for export_csv
        if action=='export_csv'
          sync = UserSync.new(self.options)
          response = sync.response.capture { sync.export_csv(io, :close_io => false) }
        elsif action=='export_csv_all'
          sync = UserSync.new(self.options)
          response = sync.response.capture { sync.export_csv(io, :close_io => false, :all_fields => true) }
        else
          sync = UserSync.new(self.options.merge(:io => io))
          ds = UserSync::DataSource.new(UserSync::CSVReader.new(self.data))
          response = sync.response.capture { sync.do_action(ds,action) }
        end

        io.flush
        io.rewind
        self.log_output = io.read
        self.response_hash = response.counts

        self.response_message = 'success'
        self.response_message = 'warnings' if response.counts[:warnings].to_i>0
        self.response_message = 'failures' if response.counts[:failures].to_i>0
      end
    rescue
      self.response_message = 'failed'
      self.log_output = "#{$!.class.name}: #{$!.message}\n#{$!.backtrace.join("\n")}"
      self.response_hash = { :exception => $!.message }
    end
    
    self.stop!
  end
  
end