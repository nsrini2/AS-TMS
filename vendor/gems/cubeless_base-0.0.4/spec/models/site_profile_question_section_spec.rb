require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteProfileQuestionSection do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :position => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    SiteProfileQuestionSection.create!(@valid_attributes)
  end
end
