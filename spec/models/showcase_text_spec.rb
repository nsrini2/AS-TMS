require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ShowcaseText do
#pending "add some examples to (or delete) #{__FILE__}"
 before(:each) do
    @showcase_text = ShowcaseText.get
    @valid_attributes = {:text => 'test'}
  end

 it "should create a new instance given valid attributes" do
    @showcase_text.attributes = @valid_attributes
    @showcase_text.should be_valid
  end
#validation for presence of text
  it "validates presence of text" do
     showcase_text = ShowcaseText.new(@valid_attributes.merge(:text => ""))
     showcase_text.should_not be_valid
  end
 it "should have a default text" do
    @showcase_text.text.should include("Welcome to the Travel Market Showcase")
end

it "should allow the text and showcase_text to be customizeable" do
    @showcase_text.update_attributes( @valid_attributes )
    @showcase_text.text.should include("test")
  
  end
  
  it "should allow the text and showcase_text to be reset back to default" do
    @showcase_text.update_attributes( @valid_attributes )
    @showcase_text.text.should include("test")
    @showcase_text.reset
    @showcase_text.text.should include("Welcome to the Travel Market Showcase")
  
  end
end
