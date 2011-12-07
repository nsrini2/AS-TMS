require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SponsorMembersController do
  before(:each) do
    login_as_sponsor_admin
  end
  
  describe "handling GET /sponsor_accounts/1/sponsors/new" do

    before(:each) do
      # @profile = mock_model(Profile)
      # @user = mock_model(User)
      SponsorAccount.stub!(:find).and_return(mock_model(SponsorAccount))
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

    it "should create a new Sponsor Member profile and user" do
      Profile.should_receive(:new).and_return(@profile)
      User.should_receive(:new).and_return(@user)
      do_get
    end

    it "should assign the new Sponsor Member profile and user for the view" do
      do_get
      assigns[:profile].should be_is_a(Profile)
      assigns[:user].should be_is_a(User)
    end
  end

  describe "handling POST /sponsor_accounts/1/sponsors" do

    def do_post
      post :create, :user => @user_params, :profile => @profile_params, :sponsor_account_id => 1
    end

    describe "permissions" do
      before(:each) do
        @profile_params = { 
          :first_name => 'first',
          :last_name => 'last',
          :screen_name => rand(10000).to_s,
          :karma_points => "100" }
        @user_params = { 
          :login => "hehe",
          :email => "hehe@burin.com"}
        @sponsor_account = mock_model(SponsorAccount, :sponsors => [], :groups => ["moo"], :save => true)
        SponsorAccount.stub!(:find).and_return(@sponsor_account)
      end
      
      it "should respond not authorized for non shady admins" do
        login_as_direct_member
        controller.should_receive(:respond_not_authorized)
        do_post
      end
    end

    describe "creating" do
      before(:each) do
        @profile_params = { 
          :first_name => 'first',
          :last_name => 'last',
          :full_name => 'first last',
          :screen_name => rand(10000).to_s,
          :karma_points => "100",
          :karma_points= => true,
          :user= => true,
          :add_roles => true,
          :sponsor_account= => true}
        @user_params = { 
          :login => "hehe",
          :email => "hehe@burin.com",
          :login= => true,
          :email= => true,
          :sync_exclude= => true }
        @sponsor_account = mock_model(SponsorAccount, :sponsors => [], :groups => ["moo"], :save => true)
        SponsorAccount.stub!(:find).and_return(@sponsor_account)
      end

      def stub_user_and_profile
        @my_user = mock_model(User, @user_params.merge({:save! => true, :valid? => true}))
        @my_profile = mock_model(Profile, @profile_params.merge({:save! => true, :valid? => true, :user => @my_user}))

        User.stub!(:new).and_return(@my_user)
        Profile.stub!(:new).and_return(@my_profile)
      end

      it "should create a new Sponsor Member" do
        # @profile = create_user_and_profile(:login => 'hehehes', :screen_name => rand(10000).to_s)
        # User.should_receive(:new).and_return(@profile.user)
        # Profile.should_receive(:new).and_return(@profile)
        stub_user_and_profile
        do_post
      end

      # it "should assign the sponsor member to the sponsor account"

      it "should save the Sponsor Member" do
        stub_user_and_profile
        do_post
        flash[:notice].should_not be_blank
      end

      it "should redirect to the sponsor groups path if no groups have been created" do
        stub_user_and_profile

        @sponsor_account.groups.stub!(:blank? => true)
        do_post
        response.should redirect_to(new_sponsor_account_sponsor_group_path(@sponsor_account))
      end

      it "should redirect to the sponsor members path if there are more than zero groups" do
        stub_user_and_profile

        @sponsor_account.groups.stub!(:blank? => false)
        do_post
        response.should redirect_to(sponsor_account_sponsor_members_path(@sponsor_account))
      end
    end


  end

  describe "handling GET /sponsor_members/1/edit" do

    before do
      #@profile = mock_model(Profile, :user => mock_model(User))
      login_as_sponsor_admin
      
      Profile.stub!(:include_sponsor_members).and_return(Profile)
      Profile.stub!(:find).and_return(@controller.current_profile)
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

    it "should find the Sponsor Member requested" do
      Profile.should_receive(:find).and_return(@controller.current_profile)
      do_get
    end

    it "should assign the found Sponsor for the view" do
      do_get
      assigns(:profile).id.should equal(@controller.current_profile.id)
    end
  end
  
end

