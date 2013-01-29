require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = Factory.build(:user)
  end


  
  it "should receive a Sabre Red welcome email if it is a Sabre Red SSO user who accepts terms and conditions" do
    @user.srw_agent_id = 1234
    @user.terms_accepted = true
    @user.stub!(:terms_accepted_was).and_return(false)
    @user.should_receive_sabre_red_welcome_email?.should be_true
  end
end
