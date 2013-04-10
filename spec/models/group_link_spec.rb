require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupLink do
    before(:each) do
    @group_link = GroupLink.new
  @valid_attributes = {:text => 'hello', :url => 'welcome', :group_id =>1}
  end

it "should create a new instance given valid attributes" do
    @group_link.attributes = @valid_attributes
	 @group_link.should be_valid
  end


#validation for presence of url
  it "validates presence of url" do
 group_link = GroupLink.new(@valid_attributes.merge(:url => ""))
group_link.should_not be_valid
end

#validation for presence of text
  it "validates presence of text" do
group_link = GroupLink.new(@valid_attributes.merge(:text => ""))
   group_link.should_not be_valid 
end


#validation for presence of group_id
  it "validates presence of group_id" do
group_link = GroupLink.new(@valid_attributes.merge(:group_id => 123))
   group_link.should be_valid 
end

 it "should belong to a Group" do
    @group_link.attributes = @valid_attributes.except(:group)
  @group_link.should have(0).error_on(:group)
  end


it "should reject duplicate bar" do
  GroupLink.create!(@valid_attributes)
  duplicate_bar = GroupLink.new(@valid_attributes)
  duplicate_bar.should_not be_valid
end

end
