require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityStreamEvent do
  
  describe "cleanup" do
    describe "old events" do
      it "should accept a max_id option" do
        ActivityStreamEvent.should_receive(:delete_all).with("id<2143")
        ActivityStreamEvent.cleanup_old_events(:max_id => 2143)
      end
      
      it "should accept a 'records_to_keep' option and perfrom accordingly" do
        ActivityStreamEvent.should_receive(:cleanup_old_events_while_keeping).with(50)
        ActivityStreamEvent.cleanup_old_events(:records_to_keep => 50)
      end
      
      it "should accept a 'earliest_date_to_keep' option and perform accordingly" do
        ActivityStreamEvent.should_receive(:cleanup_old_events_since).with("2009-07-23".to_time)
        ActivityStreamEvent.cleanup_old_events(:earliest_date_to_keep => "2009-07-23".to_time)        
      end
      
      describe "with BOTH 'records_to_keep' and 'earliest_date_to_keep' option" do
        before(:each) do
          ActivityStreamEvent.stub!(:cleanup_max_id_by_count).and_return(100)
          ActivityStreamEvent.stub!(:cleanup_max_id_by_datetime).and_return(90)
        end

        it "should use the id based on records if that number is lower" do
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_count).with(50).and_return(90)
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_datetime).with("2009-07-23".to_time).and_return(100)
          
          ActivityStreamEvent.should_receive(:cleanup_old_events_by_id).with(90)
          
          ActivityStreamEvent.cleanup_old_events(:records_to_keep => 50, :earliest_date_to_keep => "2009-07-23".to_time)                  
        end
        it "should use the id based on time if that number is lower" do
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_count).with(50).and_return(100)
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_datetime).with("2009-07-23".to_time).and_return(90)
          
          ActivityStreamEvent.should_receive(:cleanup_old_events_by_id).with(90)
          
          ActivityStreamEvent.cleanup_old_events(:records_to_keep => 50, :earliest_date_to_keep => "2009-07-23".to_time)
        end
        it "should use the id based on record if both the id from the time and the id based on record is the same" do
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_count).with(50).and_return(100)
          ActivityStreamEvent.should_receive(:cleanup_max_id_by_datetime).with("2009-07-23".to_time).and_return(100)
          
          ActivityStreamEvent.should_receive(:cleanup_old_events_by_id).with(100)
          
          ActivityStreamEvent.cleanup_old_events(:records_to_keep => 50, :earliest_date_to_keep => "2009-07-23".to_time)
        end
      end
    end
    
    describe "old events while keeping" do
      it "should take an integer limit and only leave that many and delete the rest" do
        ActivityStreamEvent.should_receive(:count_by_sql).with("select id from activity_stream_events order by created_at desc limit 10,1").and_return(231)
        ActivityStreamEvent.should_receive(:delete_all).with("id<231")

        ActivityStreamEvent.cleanup_old_events_while_keeping(10)
      end
    end

    describe "old events since" do
      it "should take a date and only keep events AFTER that date and clear the rest" do
        ActivityStreamEvent.should_receive(:count_by_sql).with("select id from activity_stream_events where created_at < '2009-07-23 00:00:00' order by created_at desc limit 1").and_return(231)
        ActivityStreamEvent.should_receive(:delete_all).with("id<231")

        ActivityStreamEvent.cleanup_old_events_since("2009-07-23".to_date)
      end
      it "should take a time and only keep events AFTER that time and clear the rest" do
        ActivityStreamEvent.should_receive(:count_by_sql).with("select id from activity_stream_events where created_at < '2009-07-23 12:00:00' order by created_at desc limit 1").and_return(231)
        ActivityStreamEvent.should_receive(:delete_all).with("id<231")

        ActivityStreamEvent.cleanup_old_events_since("2009-07-23 12:00:00".to_time)
      end
      it "should take a datetime and only keep events AFTER that datetime and clear the rest" do
        ActivityStreamEvent.should_receive(:count_by_sql).with("select id from activity_stream_events where created_at < '2009-07-23 12:00:00' order by created_at desc limit 1").and_return(231)
        ActivityStreamEvent.should_receive(:delete_all).with("id<231")

        ActivityStreamEvent.cleanup_old_events_since("2009-07-23 12:00:00".to_datetime)
      end
      it "should take a datetime based on Time.now and only keep events AFTER that datetime and clear the rest" do
        @now = Time.now
        Time.stub!(:now).and_return(@now)
        
        @then = Time.now.advance(:hours => -72)
        @then_string = @then.strftime("%Y-%m-%d %H:%M:%S")
        
        ActivityStreamEvent.should_receive(:count_by_sql).with("select id from activity_stream_events where created_at < '#{@then_string}' order by created_at desc limit 1").and_return(231)
        ActivityStreamEvent.should_receive(:delete_all).with("id<231")

        ActivityStreamEvent.cleanup_old_events_since(@then)
      end
    end

  end
  
end