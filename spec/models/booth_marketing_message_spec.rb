require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
  
describe BoothMarketingMessage do
before(:each) do
    @marketing_message = BoothMarketingMessage.new
  @valid_attributes = { :active => "true",:link_to_url => "this is text", :group_id => 1
 }
end
 it "should create a new instance given valid attributes" do
    @marketing_message.attributes = @valid_attributes
    @marketing_message.should be_valid
  end

#validation for presence of group_id
  it "validates presence of group_id" do
marketing_message= BoothMarketingMessage.new(@valid_attributes.merge(:group_id => ""))
marketing_message.should_not be_valid
end

#dependent destroy for marketing_image
it "should destroyed associated marketing_image details" do
  @marketing_message = BoothMarketingMessage.new(@marketing_message.attributes)
 marketing_image = MarketingImage.new
  @marketing_message.destroy
 MarketingImage.find_by_id(marketing_image).should be_nil
  end

it "should belong to a group" do
     @marketing_message.attributes = @valid_attributes.except(:group)
  @marketing_message.should have(0).error_on(:group)
  end


it "should always allow content Admins to edit" do
 @profile.stub!(:has_role? => true)
 @marketing_message.should be_editable_by(@profile, @group)
end

it "should get the random_active_message" do
 BoothMarketingMessage.active_messages(0).sample
      BoothMarketingMessage.active_messages(0).should_not be_nil
end





it "should find based on conditions" do
	   
	 BoothMarketingMessage.should_receive(:find).with(:all, {:conditions=>["active = ? and group_id =?", true, 1]})
        BoothMarketingMessage.active_messages(1)
      end



end
