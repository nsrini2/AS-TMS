require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe ShowcaseMarketingMessage do
before(:each) do
    @marketing_message = ShowcaseMarketingMessage.new
 @marketing_messages_attributes = { :active => "true",:link_to_url => "this is text"
 }
end



 it "should create a new instance given valid attributes" do
    @marketing_message.attributes = @valid_attributes
    @marketing_message.should be_valid
  end

#dependent destroy for marketing_image
it "should destroyed associated marketing_image details" do
  @marketing_message = ShowcaseMarketingMessage.new(@marketing_message.attributes)
 marketing_image = MarketingImage.new
  @marketing_message.destroy
 MarketingImage.find_by_id(marketing_image).should be_nil
  end


it "should always allow Sponsor Admins to edit" do
 @profile.stub!(:has_role? => true)
 @marketing_message.should be_editable_by(@profile)
end

it "should find based on conditions" do
 ShowcaseMarketingMessage.should_receive(:find).with(:all, {:conditions=> ["active = ?", true ]})  
 ShowcaseMarketingMessage.active_messages
end
 
 it "should get the random_active_message" do
 ShowcaseMarketingMessage.active_messages.sample
      ShowcaseMarketingMessage.active_messages.should_not be_nil

    end



 


end
