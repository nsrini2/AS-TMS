require 'erb'
require 'net/http'
require 'rexml/document'
require 'rexml/xpath'
require 'yaml'

module Getthere
	def self.Enabled?
		Config[:getthere_site_name] &&  Config[:getthere_user_name] && Config[:getthere_password]
	end
	
	def self.delete_past_bookings
		GetthereBooking.delete_past_bookings if Getthere::Enabled?
	end
end

module XmlUtils
	
	def find_first xml, tag
	  # puts xml
		find_by_tag xml, tag, true
	end
	
	def find_by_tag xml, tag, first = false
		values = []
		xml.scan Regexp.new("\<(#{tag})\>([^\<]+)") do |tag, value|
			if block_given?
				new_value = yield(tag, value)
				values << new_value if new_value
			else
				values << value
			end
			break if first
		end
		first ? values[0] : values
	end
	
	def stopwatch prefix = ''
		start_time = Time.now
		result = yield
		end_time = Time.now
		puts "#{prefix}: #{end_time - start_time}"
		result
	end

	def uniq_ignore_case array_of_strings
		new_array = []
		i = 0
		while i < array_of_strings.length
			j = i + 1 
			found_duplicate = false
			while j < array_of_strings.length
			  break if (found_duplicate = (array_of_strings[i].downcase == array_of_strings[j].downcase))
			  j += 1
            end
			new_array << array_of_strings[i] unless found_duplicate
			i += 1
        end
		new_array
    end
end

class DirectDataQuery
	
	include XmlUtils
	
	@@query_max_records = '100'
	@@query_time_format = '%Y-%m-%dT%H:%M:%S GMT'
	
	# MM2: Moved to instance method
	# @@default_query_start_time = '2002-11-22T00:00:00 GMT'
	
	attr_accessor :max_cycles
		
	def initialize site_name, user_name, password, forced_user_login = nil
		@site_name = site_name
		@user_name = user_name
		@password = password
		@@forced_user_login = forced_user_login
		
		@max_cycles = 2
	end
	
	def default_query_start_time
	  Time.now.advance(:months => -1).gmtime.strftime(@@query_time_format)
	end
	
	def self.forced_user_login
		@@forced_user_login
	end
	
	def now_time
		Time.now.gmtime.strftime(@@query_time_format)
	end
	
	def query_bookings
#		output = File.new('/getthere.xml','w')
    current_cycle ||= 0
		next_query = GetthereNextQuery.next_booking_query
		begin 
			puts '.'
			response = nil
			stopwatch "Query Time" do
			  ProxyUtil.net_http.start('gtxch.itn.net') do |http|
				  response =  http.post("/cgi/gtpc/gtpc","gtxmlmessage=#{build_query_booking_xml next_query.start_id}&")
			  end
			end
#			output << response.body if response
			booking_query_result = BookingQueryResultXML.new(REXML::Document.new(response.body).root) if response
			stopwatch "Process Time" do
			  if booking_query_result
				  booking_query_result.verify_status
				  next_query.start_id = booking_query_result.find_next_query_start_id
				  ActiveRecord::Base.transaction do
					  next_query.save!
					  yield booking_query_result
				  end
			  end
			end
			
			# Increment the current cycle
			current_cycle += 1
		end while booking_query_result && booking_query_result.find_number_records_returned == @@query_max_records && current_cycle < max_cycles
#		output.close
	end
	
	def build_query_booking_xml(start_id = nil)
		transaction_id = "#{now_time}.#{rand(9999)}"
		ERB.new(
		<<-EOF
		  <GTXML VERSION="1.0" TIME_STAMP="<%=now_time%>" TRANSACTION_ID="<%=transaction_id%>">
		  <HEADER>
			 <SENDER>
			   <SENDER_NAME>Studios</SENDER_NAME>
			   <SITE_NAME><%=@site_name%></SITE_NAME>
			   <USER_NAME><%=@user_name%></USER_NAME>
			   <PASSWORD><%=@password%></PASSWORD>
			 </SENDER>
			 <RECEIVER>
			   <RECEIVER_NAME>gtpartner</RECEIVER_NAME>
			 </RECEIVER>
		  </HEADER>
		  <BODY>
			 <REQUEST TYPE="query">
			   <QUERY_REQUEST TYPE="query-booking-records" DOC_VERSION="2.0" INCLUDE_SUBSITES="yes">
			   <% if start_id %>
				 <QUERY_START_ID><%=start_id%></QUERY_START_ID>
			   <% else %>
				 <QUERY_START_TIME><%= default_query_start_time%></QUERY_START_TIME>
			   <% end %>
				 <QUERY_MAX_RECORDS><%=@@query_max_records%></QUERY_MAX_RECORDS>
			   </QUERY_REQUEST>
			 </REQUEST>
		  </BODY>
		 </GTXML>
		EOF
		).result(binding)
	end
	
	def self.query_getthere_bookings forced_user_login = nil
		if Getthere::Enabled?
			dd = DirectDataQuery.new Config[:getthere_site_name], Config[:getthere_user_name], Config[:getthere_password], forced_user_login
			dd.query_bookings do |result|
				result.bookings_xml do |booking_xml|
					booking_xml.create_or_update_booking
				end
			end
		end
	end
end

class BookingQueryResultXML
	
	include XmlUtils
	
	def initialize element
		@element = element
		@xml = element.to_s
	end
	
	def find_next_query_start_id
		find_first @xml, "NEXT_QUERY_START_ID"
	end
	
	def find_number_records_returned
		find_first @xml, "RECORDS_RETURNED"
	end
	
	def verify_status
		status_code = find_first @xml, "STATUS_CODE"
		raise Exception.new("Failed Booking Query with Status Code: #{status_code}") unless status_code == '1000'
	end
	
	def bookings_xml
		REXML::XPath.each(@element,"BODY/RESPONSE/QUERY_RESPONSE/QUERY_RESULTS/BOOKING") do |booking_element|
			yield BookingXML.new(booking_element)
		end
	end
end

class BookingXML
	
	include XmlUtils
	
	def initialize b_element
		@b_element = b_element
		@xml = b_element.to_s
	end
	
	def date_time_ignores
		['BOOK_DATE_TIME','BUY_DATE_TIME']
	end
	
	def find_start_and_end_time
		date_times = find_by_tag @xml, "\\w+?_DATE_TIME" do |tag, date|
			DateTime.parse(date) unless date_time_ignores.include?(tag)
		end
		[date_times.min, date_times.max]
	end
	
	def find_itin_state
	  find_first(@xml, "ITIN_STATE")
	end
	
	def get_profile
		user = User.find_by_sso_id("sg0#{find_user_login}")
		user.profile if user
	end
	
	def find_user_login
		DirectDataQuery::forced_user_login || find_first(@xml, "USER_LOGIN")
	end
	
	def find_ord_key
		@b_element.attributes["ORD_KEY"]
	end
	
	def find_event_type
		@b_element.attributes["EVENT_TYPE"]
	end

  def has_hotels?
    REXML::XPath.first(@b_element,"HOTEL/HOTEL_LEG").to_a.size > 0
  end
	
	def hotels_xml
		REXML::XPath.each(@b_element,"HOTEL/HOTEL_LEG") do |hotel_element|
			yield BookingHotelXML.new(hotel_element)
		end
	end

	def has_air_legs?
		REXML::XPath.first(@b_element,"AIR/AIR_LEG").to_a.size > 0
  end

	def air_legs_xml
		REXML::XPath.each(@b_element,"AIR/AIR_LEG") do |air_element|
			yield BookingAirXML.new(air_element)
		end
  end

  def has_cars?
    REXML::XPath.first(@b_element,"CAR/CAR_LEG").to_a.size > 0
  end

	def cars_xml
		REXML::XPath.each(@b_element,"CAR/CAR_LEG") do |car_element|
			yield BookingCarXML.new(car_element)
		end
    end
	
	def find_properties
		properties = []
		hotels_xml do |hotel_xml|
			properties << "#{hotel_xml.find_property_id}#{'*' if hotel_xml.is_preferred?}"
		end
		properties.uniq.join ", "
	end
	
	def xml
		@xml
	end

	def find_destination_air_legs
	  destinations = []
	  origin_apt = find_first_from_apt_code
	  #puts "origin airport = #{origin_apt}"
	  i = 0
	  air_legs_xml do |as|
  		i += 1
  		leg_id = as.find_segment.match(/^L(\d+)/)[1].to_i
  		apt = as.find_to_apt_code
  		destinations[leg_id] = apt==origin_apt ? nil : as
	  end
	  #puts "number of air legs = #{i}"
	  destinations.compact!
	  if block_given?
		destinations.each do |air_xml|
		  yield air_xml
        end
      end
	  destinations
	end
	
	def find_destination_airport_codes
	  airport_codes = []
	  find_destination_air_legs do |alx|
	    airport_codes << alx.find_from_apt_code
	    airport_codes << alx.find_to_apt_code
	  end
	  airport_codes
	end

	def find_first_from_apt_code
	  from = REXML::XPath.first(@b_element,"AIR/AIR_LEG/FROM_APT_CODE")
	  from ? from.text : nil
  end

	def find_first_from_city_name
	  from = REXML::XPath.first(@b_element,"AIR/AIR_LEG/FROM_CITY_NAME")
	  from ? from.text : nil
  end


	def find_destination_cities
	  cities = Set.new
	  #puts "********find_destination_air_legs"
	  i = 0
	  find_destination_air_legs do |air_xml|
		#puts "#{i += 1} destination air city = #{air_xml.find_to_city}"
		cities << air_xml.find_to_city unless air_xml.find_to_city.blank?
      end
	  #puts "********hotels_xml"
	  i = 0
	  hotels_xml do |hotel_xml|
		#puts "#{i += 1} destination hotel city = #{hotel_xml.find_city}"
		cities << hotel_xml.find_city unless hotel_xml.find_city.blank?
      end
	  #puts "********cars_xml"
	  i = 0
	  cars_xml do |car_xml|
		#puts "#{i += 1} pick up city = #{car_xml.find_pick_up_city}"
		cities << car_xml.find_pick_up_city unless car_xml.find_pick_up_city.blank?
      end
	  uniq_ignore_case(cities.to_a).join(", ")
	end
	
	def create_or_update_booking
		if (profile = get_profile)
			booking = GetthereBooking.find_or_initialize_by_ord_key find_ord_key
			
			if find_itin_state.to_i == -1
			  return booking.destroy
			end 
			
			booking.profile = profile
			booking.xml = xml
			booking.start_location = find_first_from_city_name
			booking.locations = find_destination_cities
			booking.property_ids = find_properties
			booking.start_airport_code = find_first_from_apt_code
			booking.destination_airport_codes = find_destination_airport_codes.join(", ")
			booking.start_time, booking.end_time = find_start_and_end_time
			if booking.start_time && booking.end_time
			  booking.save!
      elsif booking.new_record?
        msg = "warning: no start and end time - skipped creating booking with ord_key = #{booking.ord_key}" 
			  puts msg
			  Rails.logger.warn msg
			else
			  booking.destroy
			end
		else
		  msg = "warning: no matching profile - skipped creating booking with ord_key = #{find_ord_key}"
		  puts msg
		  Rails.logger.warn msg
		end
	end
end

class BookingHotelXML
	include XmlUtils
	
	def initialize h_element
		@h_element = h_element
		@xml = h_element.to_s
	end

  %w(CHECKIN_DATE_TIME CHECKOUT_DATE_TIME HOTEL_CHAIN_NAME
      HOTEL_NAME HOTEL_PHONE_NBR
      HOTEL_ADDRESS_1 HOTEL_ADDRESS_2 HOTEL_ADDRESS_3 HOTEL_ADDRESS_4
      HOTEL_CITY_NAME HOTEL_STATE_NAME HOTEL_COUNTRY_NAME HOTEL_POSTAL_CODE).each do |attr|
    define_method "find_#{attr.downcase}" do
      find_first @xml, "#{attr}"
    end
  end

  def find_hotel_address(join = "\n")
    [find_hotel_address_1, 
      find_hotel_address_2, 
      find_hotel_address_3, 
      find_hotel_address_4].compact.collect{ |a| a.to_s.titlecase }.join(join)
  end
  
  def find_hotel_region(join = ", ")
    [find_hotel_city_name, 
      find_hotel_state_name, 
      find_hotel_country_name, 
      find_hotel_postal_code].compact.collect{ |a| a.to_s.titlecase }.join(join)
  end

	def find_city
		find_first @xml, "HOTEL_CITY_NAME"
    end
	
	def find_property_id
		find_first @xml, "HOT_PROP_ID"
	end
	
	def is_preferred?
		preferred = find_first(@xml, "PREFERRED")
		"Y" == preferred || "1" == preferred
	end
end

class BookingAirXML
	include XmlUtils

	def initialize a_element
		@a_element = a_element
		@xml = a_element.to_s
	end

	def find_segment
		find_first @xml, "SEGMENT"
  end
  
  def find_airline_name
		find_first @xml, "AIRLINE_NAME"    
  end
  
  def find_flight_number
		find_first @xml, "FLIGHT_NO"    
  end
  

  def find_departing_date_time
		find_first @xml, "DEPARTING_DATE_TIME"
	end

	def find_from_apt_code
		find_first @xml, "FROM_APT_CODE"
	end

	def find_from_city
		find_first @xml, "FROM_CITY_NAME"
  end

  def find_arrival_date_time
		find_first @xml, "ARRIVAL_DATE_TIME"
	end

	def find_to_apt_code
		find_first @xml, "TO_APT_CODE"
	end

	def find_to_city
		find_first @xml, "TO_CITY_NAME"
  end
end

 class BookingCarXML
	include XmlUtils

	def initialize c_element
		@c_element = c_element
		@xml = c_element.to_s
	end

  %w(VENDOR_NAME CAR_TYPE MAKE_MODEL
      PICKUP_CITY_NAME PICKUP_STATE_NAME PICKUP_COUNTRY_NAME PICKUP_DATE_TIME
      DROPOFF_CITY_NAME DROPOFF_STATE_NAME DROPOFF_COUNTRY_NAME DROPOFF_DATE_TIME).each do |attr|
    define_method "find_#{attr.downcase}" do
      find_first @xml, "#{attr}"
    end
  end

	def find_pick_up_city
		find_first @xml, "PICKUP_CITY_NAME"
    end
end

