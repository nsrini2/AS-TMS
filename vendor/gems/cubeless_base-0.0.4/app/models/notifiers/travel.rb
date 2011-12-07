class Notifiers::Travel < Notifier
  
  def new_getthere_booking(booking)
    @recipients  = booking.profile.user.email
    @subject = "Share your latest GetThere Booking"
    self.body = {:booking => booking}
  end
  
end