require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    login_as_direct_member
  end
    
  it "should respond to index" do
    pending "great 2011 migration"
    get :index
    response.should be_success
  end
  
end