require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video do
  before(:each) do
    @profile = mock_model(Profile)
    
    @valid_attributes = {
      :profile => @profile,
      :title => "value for title",
      :description => "value for description",
      :tag_list => "Tag 1"
    }
    
    @video = Video.new(@valid_attributes)
  end

  it "should create a valid instance given valid attributes" do
    @video.should be_valid
  end
end
