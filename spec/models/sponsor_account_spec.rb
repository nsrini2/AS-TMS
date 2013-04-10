require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SponsorAccount do

  before(:each) do
    @sponsor_account = SponsorAccount.new
    @valid_attributes = { 
      :name => 'Big Money Ballers', 
      :groups_allowed => 5, 
      :notes => "notes: this sponsor is ballin out of control!" }
  end

  it "should create a new instance given valid attributes" do
    @sponsor_account.attributes = @valid_attributes
    @sponsor_account.should be_valid
  end



#validation for presence of name
  it "validates presence of name" do
     sponsor_account = SponsorAccount.new(@valid_attributes.merge(:name => ""))
     sponsor_account.should_not be_valid
  end
#validation for presence of showcase_category_image
  it "validates presence of showcase_category_image" do
     sponsor_account = SponsorAccount.new(@valid_attributes.merge(:showcase_category_image => nil))
     sponsor_account.should be_valid
  end

#validation for groups_allowed not less than 0
  it "should be invalid with a group_allowed lesser than 0" do
    @sponsor_account.attributes = @valid_attributes
    @sponsor_account.groups_allowed = 'c'* 0
    @sponsor_account.should have(1).error_on(:groups_allowed)
  end
# validation for groups_allowed numericality
 it "validates numericality of groups_allowed" do
    @sponsor_account.attributes = @valid_attributes
    @sponsor_account.groups_allowed = 'abc'
    @sponsor_account.should have(1).error_on(:groups_allowed) 
  end
# validation for groups_allowed not be negative
it "should not be negative" do
     @sponsor_account.groups_allowed = 0
     @sponsor_account.valid?
     @sponsor_account.groups_allowed.should be(0)
    end




 #association for has many groups
    it "should have many groups" do
      @sponsor_account.should respond_to(:groups)
    end
 

#association for has many sponsors
it "should have many sponsors" do
      @sponsor_account.should respond_to(:sponsors)
    end

#dependent destroy for groups
it "should destroyed associated groups details" do
  @sponsor_account = SponsorAccount.new(@sponsor_account.attributes)
  group = Group.new(:sponsor_account_id => @sponsor_account.id)
  @sponsor_account.destroy
  Group.find_by_id(group.id).should be_nil
end




end
