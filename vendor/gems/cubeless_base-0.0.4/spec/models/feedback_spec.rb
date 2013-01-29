require File.dirname(__FILE__) + '/../spec_helper'

describe Feedback do
  
  def valid_attributes
    { :name => "Mark",
      :subject => "Feedback",
      :body => "I love it!",
      :email => "mark.mcspadden@sabre.com"}
  end
  
  before(:each) do
    @feedback = Feedback.new(valid_attributes)
  end
  
  # MM2
  # This uses the active_form plugin. 
  # If it breaks, it most likely the plugin or my extension to it is broken.
  it "should be valid" do
    @feedback.should be_valid
  end
  
end