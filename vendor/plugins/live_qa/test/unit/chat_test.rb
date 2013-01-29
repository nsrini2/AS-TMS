require 'test_helper'

class ChatTest < ActiveSupport::TestCase
  test "host_id title start_at duration are not nil" do
    chat = chats(:empty)
    assert chat.invalid?, ":empty chat passed validation"
    assert chat.errors[:host_id].any?
    assert chat.errors[:title].any?
    assert chat.errors[:start_at].any?
    assert chat.errors[:duration].any?
  end
  
  test "valid chat entry" do
    chat = chats(:valid)
    assert chat.valid?, ":valid chat failed validation"
  end  
  
  test "active chat is active?" do
    chat = chats(:active)
    assert chat.on_air?, ":active chat is not on_air?"
  end
  
  test "closed chat is closed?" do
    chat = chats(:closed)
    assert chat.closed?, ":closed chat is not closed?"
  end
  
  test "test participant" do
    profile = Profile.current
    chat = Chat.find(1)
    assert chat.is_participant?(profile), "#{profile.inspect} is not participating in chat: #{chat.inspect}"
  end
  
  
  test "test attendees" do
    chat = chats(:valid)
    assert chat.attendees.size == 1
  end
 
  test "computaion of start_time" do
    time = {:hour => 12, :minutes => 15, :zone => "Central Time (US & Canada)"}
    
    standard_time_date = '2011-02-28'
    adjusted_time = Chat.compute_start_at_from_input(standard_time_date, time)
    assert adjusted_time.to_s == '2011-02-28 12:15:00 -0600', "Computation of start time failed,\n adjusted time: #{adjusted_time.to_s}"
    
    daylight_time_date = '2011-05-30'
    adjusted_time = Chat.compute_start_at_from_input(daylight_time_date, time)
    puts adjusted_time.to_s == '2011-05-30 12:15:00 -0500', "Computation of start time failed,\n adjusted time: #{adjusted_time.to_s}"
  end
  
  test "find current chats" do
    active = Chat.current
    assert active.size == 1
    assert active.include? chats(:active)
  end
  
  test "find past chats" do
    past = Chat.past
    assert past.size == 2
    assert past.include? chats(:closed)
    assert past.include? chats(:valid)
    assert (past.include? chats(:inactive)) == false
  end
  
end
