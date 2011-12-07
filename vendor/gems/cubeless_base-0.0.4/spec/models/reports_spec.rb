require File.dirname(__FILE__) + '/../spec_helper'

require File.dirname(__FILE__) + '/../../app/models/reports'

describe "Reports" do
  
  it "should create a Reports::Abuse class on the fly" do
    lambda{ Reports::Abuse }.should_not raise_error
  end
  
  it "should create a Reports::Question class on the fly" do
    lambda{ Reports::Question }.should_not raise_error
  end
  
  it "should create a Reports::GroupInvitationRequest class on the fly even though it does not have it's own file" do
    lambda{ Reports::GroupInvitationRequest }.should_not raise_error
  end
  
end