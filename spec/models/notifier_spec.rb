require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do
  before(:each) do
    @profile = Factory.build(:profile, :first_name => "Create", :last_name => "Profile")
    @profile.user.stub!(:profile).and_return(@profile)
  end
  
  it "should create an email with sabre_red_sso_welcome, if deliver_sabre_red_sso_welcome is called" do
    Notifier.should_receive(:deliver_sabre_red_sso_welcome).with(@profile.user).and_return(true)
    Notifier.deliver_sabre_red_sso_welcome(@profile.user)
  end
  
  it "should create an email to welcome sabre red sso users" do
    sso_welcome_email = Notifier.create_sabre_red_sso_welcome(@profile.user)
  end
  
end  