require File.dirname(__FILE__) + '/../spec_helper'

describe ApisController, "permissions" do
  before(:each) do
    Config.merge!({'api_enabled' => true })
    
    controller.stub!(:bg_run_user_sync_job).and_return(true)    
  end

  def stub_api_key
    controller.stub!(:require_api_key).and_return(true)
  end

  it "should require an api key" do
    get :questions
    response.body.should == "Access Denied"
  end
  it "should skip authentication token verification on sync_users" do
    stub_api_key
    
    controller.should_not_receive(:verify_authenticity_token)
    post :sync_users
  end
  it "should only allow user admins to post sync_users" do
    login_as_user_admin
    stub_api_key
    
    post :sync_users, :format => "xml", :user_data => "string"
    response.should be_success
    response.body.should_not == "Access Denied"
  end
  it "should not allow normal members to post sync_users" do
    login_as_direct_member
    stub_api_key
    
    post :sync_users, :format => "xml"
    response.body.should == "Access Denied"
  end
  it "should only allow user admins to get sync_users_status" do
    login_as_user_admin
    stub_api_key
    
    get :sync_users_status, :format => "xml"
    response.should be_success
    response.body.should_not == "Access Denied"    
  end
  it "should not allow normal members to get sync_users_status" do
    login_as_direct_member
    stub_api_key
    
    get :sync_users_status, :format => "xml"
    response.body.should == "Access Denied"    
  end
end # permissions

describe ApisController do
  before(:each) do
    controller.stub!(:require_api_key).and_return(true)
    login_as_user_admin
  end

  describe "GET /sync_users" do
    before(:each) do      
      @job = mock_model(UserSyncJob, :to_xml => "<XML>", :stopped? => true, :queue! => true) 
      UserSyncJob.stub!(:instance).and_return(@job)
      
      controller.stub!(:bg_run_user_sync_job).and_return(true)
    end
        
    describe "xml" do
      def do_post(options = {})
        options = {:user_data => "string"}.merge!(options).merge!(:format => "xml")
        post :sync_users, options
      end
      it "should find the first (and only?) job instance" do
        UserSyncJob.should_receive(:instance).and_return(@job)
        
        do_post
      end
      it "should stop a previously running job if the :do param is set to 'reset'" do
        @job.should_receive(:stop!)
        do_post :do => 'reset'
      end
      it "should not stop a previously running job if the :do params is not 'reset'" do
        @job.should_not_receive(:stop!)
        do_post :do => 'not_reset'
      end
      it "should not stop a previously running job is there is no :do param" do
        @job.should_not_receive(:stop!)
        do_post
      end
      it "should check to see if another job is currently running" do
        @job.should_receive(:stopped?)
        do_post
      end
      it "should verify that the current request is a post" do
        # MM2: Do we need this? Won't Rails routes do that for us?
      end
      it "should manually set the mode to 'sync' (at least for now)" do
        # MM2: Not really sure the best way to spec this
      end
      describe "data" do
        it "should read in the contents of a file" do
          data = mock(File) #ActionController::UploadedStringIO.new
          
          data.should_receive(:read).and_return("file string")
          do_post :user_data => data
        end
        it "should read a raw string" do
          data = "string"
          do_post :user_data => data
        end
      end
      it "should setup a queue for the sync job" do
        @job.should_receive(:queue!).with(:action => 'sync', :data => 'string', :commit => true)
        do_post
      end
      describe "test_run params" do
        it "should setup a test queue if the :test_run param is set to any string" do
          @job.should_receive(:queue!).with(:action => 'sync', :data => 'string', :commit => false)
          do_post :test_run => "it is a test run"
        end
        it "should setup a test queue if the :test_run param is set to true" do
          @job.should_receive(:queue!).with(:action => 'sync', :data => 'string', :commit => false)
          do_post :test_run => true
        end
        it "should NOT setup a test queue if the :test_run param is set to false" do
          @job.should_receive(:queue!).with(:action => 'sync', :data => 'string', :commit => true)
          do_post :test_run => false
        end
      end

      it "should run the sync job (in the background)" do
        controller.should_receive(:bg_run_user_sync_job)
        do_post
      end
      it "should respond 'CSV Received'" do
        do_post
        response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<status>Success</status>"
      end

      describe "errors" do
        it "should be added if the mode is blank" do
          # mode is currently hardcoded to 'sync'
        end
        it "should be added if the user_data is blank" do
          do_post :user_data => ""
          flash[:errors].should == ["Make sure you have set the :user_data param to either a file to upload or a raw csv string."]
        end
        it "should cause an xml response" do
          do_post :user_data => ""
          response.content_type.should == "application/xml"
        end
        it "should cause a response with the errors listed" do
          do_post :user_data => ""
          response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<status>Failure</status>\n<errors>\n  <error>Make sure you have set the :user_data param to either a file to upload or a raw csv string.</error>\n</errors>"
        end
        it "should respond with an unsuccessful status" do
          do_post :user_data => ""
          response.should_not be_success
        end
        it "should handle exceptions as well" do
          pending "Not yet specced"
          
          UserSyncJob.stub!(:instance).and_raise("Big Bad Error")
          do_post
          response.body.should == ""
        end
      end
    end
    describe "html" do
      def do_post
        post :sync_users
      end      
      it "should NOT find the first (and only?) job instance" do
        UserSyncJob.should_not_receive(:instance)
        do_post     
      end
      it "should respond with 'Not supported" do
        do_post
        response.body.should == "Not supported."
      end
    end # html
    describe "json" do
      def do_post
        post :sync_users, :format => "json"
      end
      it "should NOT find the first (and only?) job instance" do
        UserSyncJob.should_not_receive(:instance)
        do_post     
      end
      it "should respond with 'Not supported.'" do
        do_post
        response.body.should == "Not supported."
      end
    end # json        
  end # POST /sync_users
  
  describe "GET /sync_users_status" do
    before(:each) do      
      @job = mock_model(UserSyncJob, :to_xml => "<XML>") 
      UserSyncJob.stub!(:instance).and_return(@job)
    end
        
    describe "xml" do
      def do_get
        get :sync_users_status, :format => "xml"
      end
      it "should find the first (and only?) job instance" do
        UserSyncJob.should_receive(:instance).and_return(@job)
        
        do_get
      end
      it "should respond with the full xml of the first (and only?) job instance" do
        do_get
        response.body.should == "<XML>"
      end
    end
    describe "html" do
      def do_get
        get :sync_users_status
      end      
      it "should NOT find the first (and only?) job instance" do
        UserSyncJob.should_not_receive(:instance)
        do_get        
      end
      it "should NOT respond with the full xml of the first (and only?) job instance" do
        do_get
        response.body.should == "Not supported."
      end
    end # html
    describe "json" do
      def do_get
        get :sync_users_status, :format => "json"
      end
      it "should NOT find the first (and only?) job instance" do
        UserSyncJob.should_not_receive(:instance)
        do_get        
      end
      it "should NOT respond with the full xml of the first (and only?) job instance" do
        do_get
        response.body.should == "Not supported."
      end
    end # json        
  end # GET /sync_users_status
  
end