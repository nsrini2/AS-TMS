require File.dirname(__FILE__) + '/../spec_helper'

describe StatusesController do
  
  before(:each) do
    login_as_direct_member
  end
  
  it "should not allow sponsor access" do
    pending "not tested yet"
  end
  
  describe "GET /statuses" do
    it "should find recent statuses" do
      Status.should_receive(:find).with(:all, :order => "created_at DESC", :page => {:size => 10, :current => nil})
      get :index
    end
    
    it "should be successful" do
      get :index
      response.should be_success
    end
  end
  
  describe "GET /profiles/1/statuses" do
    before(:each) do
      @profile = mock_model(Profile)
      Profile.stub!(:find).and_return(@profile)
    end
    
    def do_get
      get :index, :profile_id => "1"
    end
    
    it "should find the profile from the profile id" do
      Profile.should_receive(:find).with("1")
      
      do_get
    end
    
    it "should find recent statuses for that profile" do
      @named_scope = mock("NamedScope")
      
      Status.should_receive(:by_profile).with(@profile).and_return(@named_scope)
      @named_scope.should_receive(:find).with(:all, :page => {:size => 10, :current => nil})

      do_get
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
  end
  
  describe "POST /statuses" do
    before(:each) do
      @status = mock_model(Status, :save => true)
      Status.stub!(:new).and_return(@status)
      
      controller.stub!(:render).and_return("HTML")
      # controller.stub_render(:partial => "/statuses/widget_status", :locals => { :status => @status }).and_return("HTML")
    end
    
    def do_post(options={})
      options = {:status => { :body => "This is a test" } }.merge(options)
      
      post :create, options
    end
    
    it "should create a new status" do
      Status.should_receive(:new).with(:body => "This is a test", :profile_id => controller.current_profile.id).and_return(@status)
      @status.should_receive(:save).and_return(true)
      
      do_post
    end
    
    describe "successful" do
      before(:each) do
        @status.stub!(:save).and_return(true)
      end
      
      it "should render the widget status partial by default" do
        # controller.expect_render(:partial => "/statuses/widget_status", :locals => { :status => @status })
        controller.should_receive(:render).with(:partial => "widget_status", :locals => { :status => @status })
        do_post
      end
      
      it "should render the profile status partial if specified" do
        # controller.expect_render(:partial => "/statuses/profile_status", :locals => { :status => @status })
        controller.should_receive(:render).with(:partial => "profile_status", :locals => { :status => @status })
        do_post(:profile_status => true, :status => { :body => "This is a test" })
      end
    end
    
    describe "failure" do
      before(:each) do
        @status.stub!(:save).and_return(false)
      end
      
      it "should respond 'Not Saved'" do
        controller.should_receive(:render).with(:text => 'Not Saved')
        do_post
      end
    end

  end
  
end