require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = User.new()
  end
  
  describe "when using login and password" do
    before(:each) do
      @valid_attributes = {
        :login => 'test',
        :email => 'test@cubeless.com'
      }
    end
    it "should create a new instance given valid attributes" do
      pending "many more validations now"
      
      @user.login = @valid_attributes[:login]
      @user.email = @valid_attributes[:email]
      @user.should be_valid
    end
    it "should be invalid without a login" do
      @user.email = @valid_attributes[:email]
      @user.should have(1).errors_on(:login)
    end
    it "should be invalid without an email" do
      @user.login = @valid_attributes[:login]
      @user.should have(1).error_on(:email)
    end
  end
end