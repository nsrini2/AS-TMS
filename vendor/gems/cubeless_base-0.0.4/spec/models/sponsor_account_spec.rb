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

end