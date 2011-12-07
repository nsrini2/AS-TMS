require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteRegistrationField do
  before(:each) do
    @valid_attributes = {
      :label => "value for label",
      :field_name => "value for field"
    }
    
    @site_registration_field = SiteRegistrationField.new(@valid_attributes)
  end


  it "should create a new instance given valid attributes" do
    @site_registration_field.should be_valid
  end
  
  describe "validation" do
    it "should not allow special characters" do
      @site_registration_field.label = "It's great"
      @site_registration_field.should_not be_valid
    end
  end
end
