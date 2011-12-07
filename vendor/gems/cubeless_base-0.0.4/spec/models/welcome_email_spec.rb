require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WelcomeEmail do
  before(:each) do
    @email = WelcomeEmail.get
    @valid_attributes = {
      :subject => 'test',
      :content => 'testing'
    }
  end
  
  it "should have a default subject and content" do
    @email.subject.should include("Welcome to")
    @email.content.should include("community")
  end
  
  it "should be invalid without a subject" do
    @email.update_attributes( { :subject => '', :content => 'testing' } )
    @email.should have(1).errors_on(:subject)
  end
  
  it "should be invalid without content" do
    @email.update_attributes( { :subject => 'test', :content => '' } )
    @email.should have(1).errors_on(:content)
  end
  
  it "should allow the subject and email to be customizeable" do
    @email.update_attributes( @valid_attributes )
    @email.subject.should include("test")
    @email.content.should include("testing")
  end
  
  it "should allow the subject and email to be reset back to default" do
    @email.update_attributes( @valid_attributes )
    @email.subject.should include("test")
    @email.content.should include("testing")
    @email.reset
    @email.subject.should include("Welcome to")
    @email.content.should include("community")
  end
end