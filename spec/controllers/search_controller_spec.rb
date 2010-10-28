require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    login_as_direct_member
  end
  
  
  it "should respond to index" do
    get :index
    response.should be_success
  end
  
end