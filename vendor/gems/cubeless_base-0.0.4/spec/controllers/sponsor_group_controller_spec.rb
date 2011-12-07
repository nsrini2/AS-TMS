require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SponsorGroupsController do
  before(:each) do
    pending "great 2011 migration"
    
    login_as_sponsor_admin
    @sponsor_account = mock_model(SponsorAccount, :sponsors => [])
    @sponsor_account.sponsors.stub!(:find => mock_model(Profile, :is_watching? => true))
    SponsorAccount.stub!(:find => @sponsor_account)
  end
  
  describe "handling GET /sponsor_accounts/1/groups/new" do
    before(:each) do
      @sponsor_group = mock_model(Group)
      Group.stub!(:new).and_return(@sponsor_group)
    end
    
    def do_get
      get :new, :sponsor_account_id => 1
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

    it "should create a new Sponsor Group" do
      Group.should_receive(:new).and_return(@sponsor_group)
      do_get
    end

    it "should assign the new Sponsor Group for the view" do
      do_get
      assigns[:sponsor_group].should equal(@sponsor_group)
    end
    
    it "should assign the Sponsor Account for the view" do
      do_get
      assigns[:sponsor_account].should equal(@sponsor_account)
    end
  end
  
  describe "handling POST /sponsor_accounts/1/groups" do
    before(:each) do
      @sponsored_group_params = {  }
      @sponsor_group = Group.new(:name => "")
      Group.stub!(:new).and_return(@sponsor_group)
    end
    
    def do_post
      post :create, :sponsor_group => @sponsored_group_params, :sponsor_account_id => 1
    end
    
    it "should respond not authorized for non sponsor admins" do
      login_as_direct_member
      controller.should_receive(:respond_not_authorized)
      do_post
    end

    it "should create a new Sponsor Group" do
      Group.should_receive(:new).and_return(@sponsor_group)
      do_post
    end

    it "should save the Sponsor Group" do
      @sponsor_group.should_receive(:save).and_return(true)
      do_post
    end

    it "should redirect to the index" do
      do_post
      response.should redirect_to(sponsor_account_sponsor_groups_path(@sponsor_account))
    end
  end
  
end