require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GalleryPhoto do
  before(:each) do
    @photo = GalleryPhoto.new
    @profile = mock_model(Profile)
    @group = mock_model(Group)
    @valid_attributes = {
      :caption => "My Caption",
      :group => @group,
      :uploader => @profile
    }
  end

  it "should create a new instance given valid attributes" do
    @photo.attributes = @valid_attributes
    @photo.should be_valid
  end
  
  it "should be invalid with a caption longer than 256 characters" do
    @photo.attributes = @valid_attributes
    @photo.caption = 'c'*257
    @photo.should have(1).error_on(:caption)
  end
  
  it "should belong to a Group" do
    @photo.attributes = @valid_attributes.except(:group)
    @photo.should have(1).error_on(:group)
  end
  
  it "should belong to an uploader (Profile)" do
    @photo.attributes = @valid_attributes.except(:uploader)
    @photo.should have(1).error_on(:uploader)
  end

end