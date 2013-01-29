require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfileRegistrationField do
  before(:each) do
    @valid_attributes = {
      :profile_id => "1",
      :site_registration_field_id => "1",
      :value => "value for value"
    }
  end

  it "should create a new instance given valid attributes" do
    ProfileRegistrationField.create!(@valid_attributes)
  end
end
