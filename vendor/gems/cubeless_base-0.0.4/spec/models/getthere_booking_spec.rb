require File.dirname(__FILE__) + '/../spec_helper'

describe GetthereBooking do
  
  def valid_attributes
    { :ord_key => "123.456",
      :profile_id => 101,
      :xml => "<></>",
      :start_time => Time.now,
      :end_time => Time.now.advance(:days => 7) }
  end
  
  before(:each) do
    @booking = GetthereBooking.new(valid_attributes)
  end
  
  it "should create a valid instance" do
    @booking.should be_valid
  end
  
  describe "past trips" do
    it "should be trips that have already ended" do
      @booking.end_time = Time.now.advance(:days => -1)
      @booking.should be_past
    end
    it "should not be trips that are still ongoing" do
      @booking.end_time = Time.now.advance(:minutes => 5)
      @booking.should_not be_past      
    end
    it "should not be trips that have not started yet" do
      @booking.start_time = Time.now.advance(:days => 1)
      @booking.end_time = Time.now.advance(:days => 5)
      @booking.should_not be_past
    end
  end
  
end