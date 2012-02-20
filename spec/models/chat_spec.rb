require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chat do
  fixtures :chats

  
  it "starting_soon should return the starting soon fixture" do
    assert_equal 1, Chat.starting_soon.count, "Did not find any chats that matched the starting soon criteria"
    Chat.starting_soon.each do |chat|
      assert_equal chat, chats(:starting_soon), "Did not return the starting_soon fixture"
    end  
  end
  
  it "should only send staring email notification once per user/chat" do
    host = Factory.build(:user)
    host.email = "scott.johnson@sabre.com"
    Chat.should_receive(:send_batch_email).and_return(true)
    chats_to_email = Chat.starting_soon.not_notified.count
    assert chats_to_email > 0, "At least 1 chat to email is needed to test send_rsvp_emails"
    Chat.starting_soon.not_notified.each do |chat|
      chat.stub!(:host).and_return(host)
      chat.stub!(:allowed_to_create?).and_return(true)
      chat.stub!(:validate).and_return(true)
      chat.send_rsvp_email   
    end
    chats_to_email_after = Chat.starting_soon.not_notified.count
    assert_equal 0, chats_to_email_after, "Chat starting soon notifications should only be sent once."
  end
  
end
