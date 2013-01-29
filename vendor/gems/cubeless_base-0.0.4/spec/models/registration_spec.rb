require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registration do
  before(:each) do
    @registration = Registration.new
  end
  
  it "should be valid" do
    @registration.should be_valid
  end
  
  describe "finding registration fields" do
    before(:each) do
      @field = SiteRegistrationField.create(:label => "Cell Phone", :required => true)
    end
    after(:each) do
      @field.destroy
    end
    
    it "should be able to create getter methods for registration fields" do
      @registration.cell_phone.should be_nil
    end
    it "should be able to set the registration field" do
      @registration.cell_phone = "4692269488"
      @registration.cell_phone.should == "4692269488"
    end
    it "should not be valid if there's an empty required registration field" do
      @registration.cell_phone = nil
      @registration.should_not be_valid
    end
    it "should be valid if there's an empty registration field that is not required" do      
      @field.update_attribute(:required, false)
            
      @registration.cell_phone = nil
      @registration.should be_valid      
    end
  end
end