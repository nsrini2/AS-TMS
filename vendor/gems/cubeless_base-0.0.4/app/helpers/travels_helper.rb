module TravelsHelper
  
  def display_location(booking)
    text = []
		text << booking.start_location
		text << "<small>to</small>" unless booking.start_location.blank? || booking.locations.blank?
		text << "<br/>" unless booking.start_location.blank?
		text << booking.locations
		
		text.compact.join(" ")
  end
  
end