require File.dirname(__FILE__) + '/../spec_helper'

# Spec::Matchers.create :match_email do |expected|
#   match do |actual|
#     match_from(actual, expected)
#   end
# 
#   def match_from(actual, expected)
#     actual.from.should == expected.from
#   end
# end

describe Notifier do
  include EmailMatcher
  
  include MailerSpecHelper
  #include ActionMailer::Quoting
  
  CHARSET = 'iso-8859-1'


  before(:each) do
    Config.merge!({'email_from_address' => 'cubeless <no-reply@cubeless.com>'})
    
    @expected = Mail.new
    @expected.content_type ['text', 'html', { 'charset' => CHARSET }]
    @expected.mime_version = '1.0'
  end
  
  it "should create an email for a failed user sync" do    
    @user_sync_job = UserSyncJob.new
    
    @expected.from = "cubeless <no-reply@cubeless.com>"    
    @expected.to = "support@cubeless.com"
    @expected.subject = "A failed User Sync has been detected"
    @expected.body = "user sync attempt failed" #read_fixture('failed_sync_users')
    
    Notifier.create_failed_sync_users(@user_sync_job).should match_email(@expected)
  end

  it "should create a community email" do    
    @expected.from = "cubeless <no-reply@cubeless.com>"    
    @expected.to = "mark.mcspadden@sabre.com"
    @expected.subject = "Testing"
    @expected.body = "1,2,3"
    
    Notifier.create_community_email("Testing", "1,2,3", "mark.mcspadden@sabre.com").should match_email(@expected)
  end
  
end