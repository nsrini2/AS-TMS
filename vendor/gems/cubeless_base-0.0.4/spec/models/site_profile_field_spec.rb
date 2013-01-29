require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteProfileField do
  before(:each) do
    @valid_attributes = {
      :label => "value for label",
      :question => "value for question",
      :completes_profile => false,
      :matchable => false
    }
    
    @site_profile_field = SiteProfileField.new(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    @site_profile_field.should be_valid
  end
  
  it "should be sticky if the question is profile 1" do
    @site_profile_field.question = "profile_1"
    @site_profile_field.should be_sticky
  end
  
  it "should be sticky if the question is profile 2" do
    @site_profile_field.question = "profile_2"
    @site_profile_field.should be_sticky
  end
  
  it "should NOT be sticky if the question is profile 3" do
    @site_profile_field.question = "profile_3"
    @site_profile_field.should_not be_sticky
  end
  
  it "should NOT be sticky if the question is profile 10" do
    @site_profile_field.question = "profile_10"
    @site_profile_field.should_not be_sticky
  end
  
  it "should NOT be sticky if the question is profile 20" do
    @site_profile_field.question = "profile_20"
    @site_profile_field.should_not be_sticky
  end    
end
