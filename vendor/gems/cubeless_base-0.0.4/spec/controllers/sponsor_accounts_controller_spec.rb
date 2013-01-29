require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SponsorAccountsController do
  before(:each) do
    pending "great 2011 migration"
    
    login_as_sponsor_admin
  end

  describe "route recognition" do
    it "should generate params { :controller => 'sponsor_accounts', :action => 'index' } from GET /sponsor_accounts" do
      params_from(:get, "/sponsor_accounts").should == {:controller => "sponsor_accounts", :action => "index"}
    end
    it "should generate params { :controller => 'sponsor_accounts', :action => 'new' } from GET /sponsor_accounts/new" do
      params_from(:get, "/sponsor_accounts/new").should == {:controller => "sponsor_accounts", :action => "new"}
    end
    it "should generate params { :controller => 'sponsor_accounts', :action => 'edit', :id => '1' } from GET /sponsor_accounts/1/edit" do
      params_from(:get, "/sponsor_accounts/1/edit").should == {:controller => "sponsor_accounts", :action => "edit", :id => "1"}
    end
    it "should generate params { :controller => 'sponsor_accounts', :action => 'create' } from POST /sponsor_accounts" do
      params_from(:post, "/sponsor_accounts").should == {:controller => "sponsor_accounts", :action => "create"}
    end
    it "should generate params { :controller => 'sponsor_accounts', :action => 'update', :id => '1' } from PUT /sponsor_accounts/1" do
      params_from(:put, "/sponsor_accounts/1").should == {:controller => "sponsor_accounts", :action => "update", :id => "1"}
    end
    it "should generate params { :controller => 'sponsor_accounts', :action => 'destroy', :id => '1' } from DELETE /sponsor_accounts/1" do
      params_from(:delete, "/sponsor_accounts/1").should == {:controller => "sponsor_accounts", :action => "destroy", :id => "1"}
    end
  end

  describe "handling GET /sponsor_accounts" do
    before(:each) do
      @sponsor_account = mock_model(SponsorAccount)
      SponsorAccount.stub!(:find).and_return([@sponsor_account])
    end

    def do_get
      get :index
    end
  
    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_get
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render sponsor_accounts template" do
      do_get
      response.should render_template('index')
    end

    it "should find all Sponsor Accounts" do
      SponsorAccount.should_receive(:find).with(:all).and_return([@sponsor_account])
      do_get
    end

    it "should assign the found weathers for the view" do
      do_get
      assigns[:sponsor_accounts].should == [@sponsor_account]
    end
  end

  describe "handling GET /sponsor_accounts/new" do

    before(:each) do
      @sponsor_account = mock_model(SponsorAccount)
      SponsorAccount.stub!(:new).and_return(@sponsor_account)
    end

    def do_get
      get :new
    end

    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_get
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should create a new Sponsor Account" do
      SponsorAccount.should_receive(:new).and_return(@sponsor_account)
      do_get
    end

    it "should assign the new Sponsor Account for the view" do
      do_get
      assigns[:sponsor_account].should equal(@sponsor_account)
    end
  end

  describe "handling GET /sponsor_accounts/1/edit" do

    before do
      @sponsor_account = mock_model(SponsorAccount)
      SponsorAccount.stub!(:find).and_return(@sponsor_account)
    end

    def do_get
      get :edit, :id => "1"
    end

    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_get
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the Sponsor Account requested" do
      SponsorAccount.should_receive(:find).and_return(@sponsor_account)
      do_get
    end

    it "should assign the found Sponsor Account for the view" do
      do_get
      assigns[:sponsor_account].should equal(@sponsor_account)
    end
  end

  describe "handling POST /sponsor_accounts" do

    before(:each) do
      @params = { "name" => 'Big Money Ballers' }
      @sponsor_account = mock_model(SponsorAccount, :name => 'Big Money Ballers', :to_param => "1", :save => true)
      SponsorAccount.stub!(:new).and_return(@sponsor_account)
    end

    def do_post
      post :create, :sponsor_account => @params
    end

    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_post
    end

    it "should create a new Sponsor Account" do
      SponsorAccount.should_receive(:new).with(@params).and_return(@sponsor_account)
      do_post
    end

    it "should save the Sponsor Account" do
      @sponsor_account.should_receive(:save).and_return(true)
      do_post
    end

    it "should redirect to the index" do
      do_post
      response.should redirect_to(sponsor_accounts_url)
    end
  end

  describe "handling PUT /sponsor_accounts/1" do

    before(:each) do
      @sponsor_account = mock_model(SponsorAccount, :to_param => "1", :update_attributes => true)
      SponsorAccount.stub!(:find).and_return(@sponsor_account)
    end

    def do_update
      put :update, :id => "1"
    end

    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_update
    end

    it "should find the Sponsor Account requested" do
      SponsorAccount.should_receive(:find).with("1").and_return(@sponsor_account)
      do_update
    end

    it "should update the found Sponsor Account" do
      @sponsor_account.should_receive(:update_attributes)
      do_update
    end

    it "should assign the updated Sponsor Account for the view" do
      do_update
      assigns(:sponsor_account).should equal(@sponsor_account)
    end

    it "should redirect to the index" do
      do_update
      response.should redirect_to(sponsor_accounts_url)
    end
  end

  describe "handling DELETE /sponsor_accounts/1" do

    before(:each) do
      @sponsor_account = mock_model(SponsorAccount, :destroy => true, :name => 'Test Account')
      SponsorAccount.stub!(:find).and_return(@sponsor_account)
    end

    def do_delete
      delete :destroy, :id => "1", :commit => 'Yes'
    end

    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_delete
    end

    it "should find the Sponsor Account requested" do
      SponsorAccount.should_receive(:find).with("1").and_return(@sponsor_account)
      do_delete
    end

    it "should call destroy on the found Sponsor Account" do
      @sponsor_account.should_receive(:destroy)
      do_delete
    end

    it "should redirect to the index" do
      do_delete
      response.should redirect_to(sponsor_accounts_url)
    end
  end

end