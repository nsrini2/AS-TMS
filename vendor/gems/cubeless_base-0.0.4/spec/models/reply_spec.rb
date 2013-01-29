require File.dirname(__FILE__) + '/../spec_helper'

describe Reply do
  
  def valid_attributes
    { :text => "Hi." }
  end

  before(:each) do
    @reply = Reply.new(valid_attributes)
  end
  
  it "should have a valid instance" do
    @reply.should be_valid
  end
  
  describe "text length" do
    it "should not be empty" do
      @reply.text = nil
      @reply.should_not be_valid
    end
    
    it "should not be over 4000" do
      t = "i"
      4000.times { t << "i" }
      
      @reply.text = t
      @reply.should_not be_valid
    end
  end
  
end