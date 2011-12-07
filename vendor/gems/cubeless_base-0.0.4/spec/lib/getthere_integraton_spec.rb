require File.dirname(__FILE__) + '/../spec_helper'

class DirectDataQuery
  def self.set_query_max_records(value)
    @@query_max_records = value.to_i.to_s
  end
end

describe "GetthereIntegration" do
  
  before(:each) do
    @user = mock_model(User)
    User.stub!(:find_by_sso_id).and_return(@user)

    @profile = mock_model(Profile)
    Profile.stub!(:first).and_return(@profile)
    
    @user.stub!(:profile).and_return(@profile)
        
    @ddq = DirectDataQuery.new("test_site", "test_user", "test_password")
    
    stub_fetch
  end
  
  def stub_fetch(xml_file = nil)
    path = File.exists?("#{Rails.root}/spec/fixtures/getthere_bookings.xml") ? "#{Rails.root}/spec/fixtures/getthere_bookings.xml" : "#{CubelessBase::Engine.root}/spec/fixtures/getthere_bookings.xml"
    @xml_file = xml_file || File.read(path)    
	  
	  # Stub out the xml fetch
	  response = mock(Net::HTTPResponse)
	  response.stub!(:body).and_return(@xml_file)
	  
	  http = mock("http")
	  http.stub!(:post).and_return(response)

	  @net_http = mock("net_http")
	  @net_http.stub!(:start).and_yield(http)
	  
	  ProxyUtil.stub!(:net_http).and_return(@net_http)
  end

  describe "query bookings" do
    it "should only cycle through the max number of times if each request returns the max number of records" do      
      DirectDataQuery.set_query_max_records(10)
      
      ProxyUtil.should_receive(:net_http).exactly(2).times.and_return(@net_http)
      
      @ddq.query_bookings { |qb| qb }
    end
    
    it "should stop querying if a result returns without the max number of records" do
      path = File.exist?("#{Rails.root}/spec/fixtures/getthere_bookings_short.xml") ? "#{Rails.root}/spec/fixtures/getthere_bookings_short.xml" : "#{CubelessBase::Engine.root}/spec/fixtures/getthere_bookings_short.xml"
      stub_fetch File.read(path)    
      
      ProxyUtil.should_receive(:net_http).exactly(1).times.and_return(@net_http)
      
      @ddq.query_bookings { |qb| qb }
    end
  end

  describe "build query booking xml" do
    before(:each) do
      # Stubbing rand...I would like that stubbing it at Kernel would work...but it doesn't seem to.
      @ddq.should_receive(:rand).and_return(2701)
      
      # Stub the time
      @now = "2009-07-19T13:00:00 GMT".to_time
      Time.stub!(:now).and_return(@now)
    end
    
    it "should create a valid xml request based on date when no GetthereNextQuery record is present" do                  
      valid_xml = <<-EOXML 
      <GTXML VERSION="1.0" TIME_STAMP="2009-07-19T13:00:00 GMT" TRANSACTION_ID="2009-07-19T13:00:00 GMT.2701">
  		  <HEADER>
  			 <SENDER>
  			   <SENDER_NAME>Studios</SENDER_NAME>
  			   <SITE_NAME>test_site</SITE_NAME>
  			   <USER_NAME>test_user</USER_NAME>
  			   <PASSWORD>test_password</PASSWORD>
  			 </SENDER>
  			 <RECEIVER>
  			   <RECEIVER_NAME>gtpartner</RECEIVER_NAME>
  			 </RECEIVER>
  		  </HEADER>
  		  <BODY>
  			 <REQUEST TYPE="query">
  			   <QUERY_REQUEST TYPE="query-booking-records" DOC_VERSION="2.0" INCLUDE_SUBSITES="yes">

  				 <QUERY_START_TIME>2009-06-19T13:00:00 GMT</QUERY_START_TIME>

  				 <QUERY_MAX_RECORDS>10</QUERY_MAX_RECORDS>
  			   </QUERY_REQUEST>
  			 </REQUEST>
  		  </BODY>
  		 </GTXML>
  		EOXML
      
      xml = @ddq.build_query_booking_xml
      xml.gsub(/\s/,"").should == valid_xml.gsub(/\s/, "")
    end
    
    it "should create a vliad xml request based on GetthereNextQuery start_id" do
      valid_xml = <<-EOXML 
      <GTXML VERSION="1.0" TIME_STAMP="2009-07-19T13:00:00 GMT" TRANSACTION_ID="2009-07-19T13:00:00 GMT.2701">
  		  <HEADER>
  			 <SENDER>
  			   <SENDER_NAME>Studios</SENDER_NAME>
  			   <SITE_NAME>test_site</SITE_NAME>
  			   <USER_NAME>test_user</USER_NAME>
  			   <PASSWORD>test_password</PASSWORD>
  			 </SENDER>
  			 <RECEIVER>
  			   <RECEIVER_NAME>gtpartner</RECEIVER_NAME>
  			 </RECEIVER>
  		  </HEADER>
  		  <BODY>
  			 <REQUEST TYPE="query">
  			   <QUERY_REQUEST TYPE="query-booking-records" DOC_VERSION="2.0" INCLUDE_SUBSITES="yes">

  				 <QUERY_START_ID>1227</QUERY_START_ID>

  				 <QUERY_MAX_RECORDS>10</QUERY_MAX_RECORDS>
  			   </QUERY_REQUEST>
  			 </REQUEST>
  		  </BODY>
  		 </GTXML>
  		EOXML
      
      xml = @ddq.build_query_booking_xml(1227)
      xml.gsub(/\s/,"").should == valid_xml.gsub(/\s/, "")      
    end
  end


  describe "accessing xml attributes" do
    before(:each) do
      path = File.exist?("#{RAILS_ROOT}/spec/fixtures/getthere_bookings_short.xml") ? "#{Rails.root}/spec/fixtures/getthere_bookings_short.xml" : "#{CubelessBase::Engine.root}/spec/fixtures/getthere_bookings_short.xml"
      xml = File.read(path)
      
      @booking_xmls = []

      @ddq.query_bookings do |result|
        result.bookings_xml do |booking_xml|
					@booking_xmls << booking_xml #.create_or_update_booking
				end
      end

      @booking_xml = @booking_xmls.first
    end
    it "should get the event type" do
      @booking_xml.find_event_type.should == "ubr_event"
    end
    it "should get the itin state" do
      @booking_xml.find_itin_state.should == "1"
    end
  end
  
  describe "building local bookings from queries" do
    before(:each) do
      GetthereBooking.delete_all

      # stub_fetch File.read("#{RAILS_ROOT}/spec/fixtures/getthere_bookings_short.xml")    

      @booking = GetthereBooking.new
      GetthereBooking.stub!(:new).and_return(@booking)

      @booking_xmls = []

      @ddq.query_bookings do |result|
        result.bookings_xml do |booking_xml|
					@booking_xmls << booking_xml #.create_or_update_booking
				end
      end

      @booking_xml = @booking_xmls.first
    end
    
    # MM2: This isn't exactly how we check to see if we should add new bookings
    # We _could_ given what we get from GetThere, but...
    # Using our Rails record to determine when to create/update records is a little more flexible
    #
    # it "should create a new booking if it's a new online booking (nob_event)"
    # it "should create a new booking if it's a new acquired booking (nab_event)"
    # it "should update a booking if it's an updated booking (ubr_event) and it's not canceled (itin_state != -1)"
    # it "should destroy a booking if it's an updated booking (ubr_event) and it's canceled (itin_state == -1)"
        
    describe "creating and updating bookings" do
      before(:each) do
        @booking.should_not_receive(:destroy).and_return(@booking)
        @booking.should_receive(:save!).and_return(true)        
      end
      
      it "should replace a booking if it has a itin status of -2" do
        @booking_xml.should_receive(:find_itin_state).and_return("-2")

        @booking_xml.create_or_update_booking        
      end
      it "should replace a booking if it has a itin status of 0" do
        @booking_xml.should_receive(:find_itin_state).and_return("0")

        @booking_xml.create_or_update_booking        
      end
      it "should replace a booking if it has a itin status of 1" do
        @booking_xml.should_receive(:find_itin_state).and_return("1")

        @booking_xml.create_or_update_booking        
      end
      it "should replace a booking if it has a itin status of 2" do
        @booking_xml.should_receive(:find_itin_state).and_return("2")

        @booking_xml.create_or_update_booking        
      end
    end # creating and updating bookings
    
    describe "destroying bookings" do
      before(:each) do
        @booking.should_receive(:destroy).and_return(@booking)
        @booking.should_not_receive(:save!).and_return(true)        
      end
      
      it "should destroy a booking if it has a itin status of -1" do
        @booking_xml.should_receive(:find_itin_state).and_return("-1")

        @booking_xml.create_or_update_booking        
      end
    end # destroying bookings
  end
  
  describe "populating local properties" do
    describe "airport codes" do
      before(:each) do
        GetthereBooking.delete_all

        @profile = mock_model(Profile)
        Profile.stub!(:first).and_return(@profile)

        path = File.exist?("#{RAILS_ROOT}/spec/fixtures/getthere_bookings_short.xml") ? "#{Rails.root}/spec/fixtures/getthere_bookings_short.xml" : "#{CubelessBase::Engine.root}/spec/fixtures/getthere_bookings_short.xml"
        stub_fetch File.read(path)    

        @booking = GetthereBooking.new
        @booking.stub!(:save!).and_return(@booking)
        GetthereBooking.stub!(:new).and_return(@booking)

        @bookings = []

        @ddq.query_bookings do |result|
          result.bookings_xml do |booking_xml|
  					@bookings << booking_xml.create_or_update_booking
  				end
        end

        @booking = @bookings.first
      end
      
      it "should find the destination airport codes and stick them in the airport_codes field" do
        @booking.destination_airport_codes.should == "CGH, SDU"
      end
      
      it "should find the start airport code" do
        @booking.start_airport_code.should == "CGH"
      end
    end
  end
end