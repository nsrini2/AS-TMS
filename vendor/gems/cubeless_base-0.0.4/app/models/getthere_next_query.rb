class GetthereNextQuery < ActiveRecord::Base
  
  validates_presence_of :request_type
  
  def self.next_profile_query
    GetthereNextQuery.find_or_create_by_request_type 'query-user-profiles'
  end
  
  def self.next_booking_query
    GetthereNextQuery.find_or_create_by_request_type 'query-booking-records'
  end
 
end