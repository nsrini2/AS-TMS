require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Profile do
  before(:each) do
    @profile = Factory.build(:profile, :first_name => "Create", :last_name => "Profile", :status => 1)
    @compnay_profile = Factory.build(:company_profile, :first_name => "Create", :last_name => "Profile")
  end

  it "should be company? if it belongs to a company" do
    @compnay_profile.should be_company
  end
  
  it "should not be company? if it does not belong to a company" do
     @profile.should_not be_company
  end
  
  it "should receive a welcome email if they are new && active members changing from inactive and not Sabre Red SSO users" do   
    @profile.stub!(:new_user?).and_return(true)
    @profile.stub!(:status_was).and_return(-3)
    @profile.user.srw_agent_id = nil
    @profile.should be_should_receive_welcome_email
  end 
  
  it "should receive a welcome email if they are new && status == activate_on_login (2) " do   
    @profile.stub!(:new_user?).and_return(true)
    @profile.stub!(:status).and_return(2)
    @profile.stub!(:is_was).and_return(nil)
    @profile.should be_should_receive_welcome_email
  end
  
  it "should NOT receive a welcome email if they are NOT new && active members changing from inactive and not Sabre Red SSO users" do 
    @profile.stub!(:new_user?).and_return(false)
    @profile.stub!(:status_was).and_return(-3)
    @profile.user.srw_agent_id = nil
    @profile.should_not be_should_receive_welcome_email
  end 
  
  it "should NOT receive a welcome email if they are new && NOT active members changing from inactive and not Sabre Red SSO users" do
    @profile.stub!(:new_user?).and_return(true)
    @profile.stub!(:status_was).and_return(1)
    @profile.user.srw_agent_id = nil
    @profile.should_not be_should_receive_welcome_email
  end
  
  it "should NOT receive a welcome email if they are Sabre Red SSO users" do
    @profile.user.srw_agent_id = 1234
    @profile.should_not be_should_receive_welcome_email
  end
  
end
