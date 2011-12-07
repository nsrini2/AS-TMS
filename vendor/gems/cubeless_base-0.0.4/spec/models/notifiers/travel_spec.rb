require File.dirname(__FILE__) + '/../../spec_helper'

describe Notifiers::Travel do
  include EmailMatcher
  
  include MailerSpecHelper
  include ActionMailer#::Quoting
  
  ActionMailer::Base.default_url_options[:host] = "example.org"
  
  CHARSET = 'iso-8859-1'

  before(:each) do
    Config.merge!({'email_from_address' => 'cubeless <no-reply@cubeless.com>'})    
    
    @expected = Mail.new
    @expected.set_content_type ['text', 'html', { 'charset' => CHARSET }]
    @expected.mime_version = '1.0'
  end
  
  it "should create an email for a new booking" do
    user = mock_model(User, :email => "test@example.org")
    profile = mock_model(Profile, :user => user)
    booking = mock_model(GetthereBooking, :profile => profile, :id => 1107, :to_param => "1107")
    
    @expected.from = "cubeless <no-reply@cubeless.com>"    
    @expected.to = profile.user.email
    @expected.subject = "Share your latest GetThere Booking"
    @expected.body = "share your travel itinerary" # read_fixture('new_getthere_booking','travel')
    
    Notifiers::Travel.create_new_getthere_booking(booking).should match_email(@expected)
  end
  
end