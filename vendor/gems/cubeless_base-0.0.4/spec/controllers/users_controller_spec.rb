require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  before(:each) do
    login_as_user_admin
    
    @profile = mock_model(Profile)
    @user = mock_model(User, :profile => @profile)
  end
  
  describe "GET index" do
    it "should be successful" do      
      get :index
      response.should be_success
    end
  end
  
  describe "GET edit" do
    it "should be successful" do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      
      get :edit, :id => @user.id.to_s
      response.should be_success
    end
  end
  
  describe "GET new" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end
  
  describe "POST create" do
    it "should redirect if 'reset' was chosen" do
      post :create, :reset => true
      response.should redirect_to(users_path)
    end
    
    it "should create a user and profile and redirect to user list" do
      User.should_receive(:new).and_return(@user)
      Profile.should_receive(:new).and_return(@profile)
      
      @user.should_receive(:attributes=).and_return(@user)
      @user.should_receive(:login=).and_return(@user)      
      @user.should_receive(:sync_exclude=).and_return(@user)      
      @user.should_receive(:valid?).and_return(true)
      @user.should_receive(:save!).and_return(true)
      
      @profile.should_receive(:karma_points=).and_return(@profile)
      @profile.should_receive(:attributes=).and_return(@profile)      
      @profile.should_receive(:roles=).and_return(@profile)      
      @profile.should_receive(:has_role?).and_return(true)
      @profile.should_receive(:user=).and_return(@profile)      
      @profile.should_receive(:valid?).and_return(true)
      @profile.should_receive(:save!).and_return(true)      
      
      post :create, :user => {}, :profile => {}
      response.should redirect_to users_path
    end
  end
  
  describe "PUT update" do
    it "should redirect if 'reset' was chosen" do
      put :update, :id => @user.id.to_s, :reset => true
      response.should redirect_to(users_path)
    end
    
    it "should update a user and profile and redirect to user list" do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      @user.should_receive(:profile).and_return(@profile)
      
      @user.should_receive(:attributes=).and_return(@user)
      @user.should_receive(:login=).and_return(@user)      
      @user.should_receive(:sync_exclude=).and_return(@user)      
      @user.should_receive(:valid?).and_return(true)
      @user.should_receive(:save!).and_return(true)
      
      @profile.should_receive(:karma_points=).and_return(@profile)
      @profile.should_receive(:attributes=).and_return(@profile)      
      @profile.should_receive(:roles=).and_return(@profile)      
      @profile.should_receive(:has_role?).and_return(true)
      @profile.should_receive(:valid?).and_return(true)
      @profile.should_receive(:save!).and_return(true)      
      
      put :update, :id => @user.id.to_s, :user => {}, :profile => {}
      response.should redirect_to users_path
    end
  end
  
  describe "DELETE destroy" do
    it "should set the profile status to -1 and redirect to users list" do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      
      @profile.should_receive(:status=).with(-1)
      @profile.should_receive(:save).and_return(true)
      
      delete :destroy, :id => @user.id.to_s
      response.should redirect_to users_path
    end
  end
  
  describe "POST clear_lock" do
    it "should unlock a profile and redirect to users list" do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      
      @user.should_receive(:update_attributes).with('locked_until' => nil).and_return(true)
      
      post :clear_lock, :id => @user.id.to_s
      response.should redirect_to users_path
    end
  end
  
  describe "POST activate" do
    it "should unlock a profile and redirect to users list" do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      
      @user.profile.should_receive(:update_attributes).with('status' => 1, 'visible' => 1).and_return(true)
      
      post :activate, :id => @user.id.to_s
      response.should redirect_to users_path
    end
  end  
  
  describe "POST resend_welcome" do
    it "should resend the welcome email and redirect to users list" do
      @now = Time.now
      Time.stub!(:now).and_return(@now)
      
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      
      @user.stub!(:email).and_return("mark@example.com")
   
      @profile.should_receive(:last_sent_welcome_at=).and_return(true)
      
      @user.should_receive(:generate_temp_crypted_password).with(7.days.from_now)
      @user.should_receive(:save_without_validation)
      Notifier.should_receive(:deliver_welcome).with(@user)
      
      post :resend_welcome, :id => @user.id.to_s
      response.should redirect_to users_path
    end
  end
  
end