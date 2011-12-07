class GetthereBookingTextIndex < ActiveRecord::Base

  belongs_to :getthere_booking

  xss_terminate :except => self.column_names

end
