require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteProfileQuestion do
  before(:each) do
    @valid_attributes = {
      :label => "value for label",
      :question => "value for question",
      :example => "value for example",
      :completes_profile => false,
      :matchable => false,
      :site_profile_question_section_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    SiteProfileQuestion.create!(@valid_attributes)
  end
end
