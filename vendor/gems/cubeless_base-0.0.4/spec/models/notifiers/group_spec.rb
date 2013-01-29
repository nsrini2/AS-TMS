require File.dirname(__FILE__) + '/../../spec_helper'

describe Notifiers::Group do
  include EmailMatcher
  
  include MailerSpecHelper
  include ActionMailer#::Quoting
  
  CHARSET = 'iso-8859-1'

  ActionMailer::Base.default_url_options[:host] = "example.org"

  before(:each) do
    Config.merge!({'email_from_address' => 'cubeless <no-reply@cubeless.com>'})
    
    @expected = Mail.new
    @expected.set_content_type ['text', 'html', { 'charset' => CHARSET }]
    @expected.mime_version = '1.0'
  end
  
  it "should create an email for a new comment on the group post" do
    user = mock_model(User, :email => "test@example.org")
    profile = mock_model(Profile, :user => user, :email => user.email)
    
    user2 = mock_model(User, :email => "test2@example.org")
    profile2 = mock_model(Profile, :user => user2, :screen_name => "Shevawn McSpadden")
    
    group = mock_model(Group, :name => "Test Group", :id => 7)
    group_post = mock_model(GroupPost, :profile => profile, :group => group, :id => 21)
    comment = mock_model(Comment, :owner => group_post, :profile => profile2, :text => "I agree")
    
    @expected.from = "cubeless <no-reply@cubeless.com>"    
    @expected.to = "test@example.org"
    @expected.subject = "Test Group just received a new reply to your group talk thread"
    @expected.body = "comment" # read_fixture('new_comment_on_group_post','group')
    
    Notifiers::Group.create_new_comment_on_group_post(comment).should match_email(@expected)
  end
  
end