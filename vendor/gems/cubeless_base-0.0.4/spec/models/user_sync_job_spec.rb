require File.dirname(__FILE__) + '/../spec_helper'

describe UserSyncJob do
  
  before(:each) do
    @job = UserSyncJob.new
  end
  
  describe "run" do
    before(:each) do
      @job.stub!(:backup!).and_return(true)
      @job.stub!(:status).and_return("queued")      
      @job.stub!(:data).and_return("first_name,last_name,login,email\nMark,McSpadden,markmcspadden,mark.mcspadden@sabre.com")
      
      @counts = {}
      @response = {}
      @response.stub!(:capture).and_return(@response)
      @response.stub!(:counts).and_return(@counts)
      
      @sync = mock(UserSync, :response => @response)
      UserSync.stub!(:new).and_return(@sync)
    end

    it "should run" do
      pending "great 2011 migration"
      @job.should_not_receive(:puts).with("FakeMailer")
      
      @job.run
    end
    
    describe "failures" do
      before(:each) do
        @options = {:action => "upload", :commit => true}
        
        @job.stub!(:status).and_return("queued")
        @job.stub!(:options).and_return(@options)
      end
      
      it "should send an email if it has failures" do
        @counts[:failures] = 2
        @options[:action] = "sync"
        
        Notifier.should_receive(:deliver_failed_sync_users)

        @job.run       
      end
      it "should send an email if it fails" do
        @options[:action] = "sync"
        
        Tempfile.should_receive(:open).and_raise("EXCEPTION")

        Notifier.should_receive(:deliver_failed_sync_users)

        @job.run
      end
    end
  end # run
  
  describe "backup" do
    before(:each) do
      # @user_sync = mock_model(UserSync, :export_csv => true)
      @user_sync = mock(UserSync, :export_csv => true)
      UserSync.stub!(:new).and_return(@user_sync)
      
      @now = "2005-07-23 14:00:00".to_time # "1122148800"
      Time.stub!(:now).and_return(@now)
      
      @job.stub!(:system).and_return(true)
      File.stub!(:delete).and_return(true)
    end
    
    it "should grab the current time to be used later" do
      Time.should_receive(:now).at_least(1).times.and_return(@now)
      @job.backup!
    end
    
    it "should create /db/sync_users_backups/ if it doesn't exist" do
      File.stub!(:exists?).with("#{RAILS_ROOT}/db/sync_users_backups").and_return(false)
      File.should_receive(:makedirs).with("#{RAILS_ROOT}/db/sync_users_backups")
      
      @job.backup!      
    end
    it "should not create /db/sync_users_backups/ if it does exist" do
      File.stub!(:exists?).with("#{RAILS_ROOT}/db/sync_users_backups").and_return(true)
      File.should_not_receive(:makedirs)
      
      @job.backup!
    end
    
    it "should create a new user_sync object" do
      UserSync.should_receive(:new).and_return(@user_sync)
      
      @job.backup!
    end
    
    it "should export a csv to /db/sync_users_backups" do
      @user_sync.should_receive(:export_csv).with("#{RAILS_ROOT}/db/sync_users_backups/1122148800.csv")
      
      @job.backup!
    end
    
    it "should compress the file" do
      @job.should_receive(:system).with("cd #{RAILS_ROOT}/db/sync_users_backups && tar -zcf 1122148800.csv.tar.gz 1122148800.csv")
      
      @job.backup!
    end
    
    it "should remove the original file" do
      File.should_receive(:delete).with("#{RAILS_ROOT}/db/sync_users_backups/1122148800.csv")
      
      @job.backup!
    end
    
    it "should make a call to clean up the archives" do
      @job.should_receive(:clean_up_archives!)
      
      @job.backup!
    end
  end # backup!
  
  describe "clean up archives" do
    before(:each) do
      @now = "2005-07-23 14:00:00".to_time # "1122148800"
      Time.stub!(:now).and_return(@now)
      
      @entries = %w(. .. 1122148800.csv.tar.gz 1002148801.csv.tar.gz 1122148802.csv.tar.gz 1122148803.csv.tar.gz 1122148804.csv.tar.gz 1122148805.csv.tar.gz 1122148806.csv.tar.gz 1122148807.csv.tar.gz)
      
      Dir.stub!(:entries).and_return(@entries)
      File.stub!(:delete).and_return(true)
    end
    
    def clean_up_archives!
      @job.clean_up_archives!("#{RAILS_ROOT}/db/sync_users_backups")
    end
    
    it "should grab the current time to be used later" do
      Time.should_receive(:now).at_least(1).times.and_return(@now)
      clean_up_archives!
    end
    
    it "should loop through the entries if there are more than 7" do
      Dir.should_receive(:entries).twice.and_return(@entries)
      
      clean_up_archives!
    end
    it "should not loop through the entries if there are less than 7" do
      Dir.should_receive(:entries).exactly(1).times.and_return(%w(. .. stuff))
      
      clean_up_archives!
    end
    it "should remove an entry that is longer than 1 month ago" do
      File.should_receive(:delete).with("#{RAILS_ROOT}/db/sync_users_backups/1002148801.csv.tar.gz")
      
      clean_up_archives!
    end
  end
  
  describe "start" do
    describe "backup" do
      it "should backup things first if it's a live sync" do
        @job.stub!(:options).and_return({:action => "sync", :commit => true})
        
        @job.should_receive(:backup!)

        @job.start!
      end
      it "should backup things first if it's a live sync" do
        @job.should_not_receive(:backup!)

        @job.start!
      end
    end # backup
  end # start
  
  describe "stop" do
    it "should update the job's attributes" do
      @job.should_receive(:update_attributes!)
      
      @job.stop!
    end
    
    describe "alerts" do      
      it "should email support if a live sync fails" do
        @options = {:action => "sync", :commit => true}
        
        @job.stub!(:options).and_return(@options)
        @job.stub!(:response_message).and_return("failures")
        
        Notifier.should_receive(:deliver_failed_sync_users).with(@job)
        
        @job.stop!
      end
    end
  end
  
end