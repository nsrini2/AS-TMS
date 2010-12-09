module TrackerExtensions
  # SSJ: method to track code happenings...
  def here(marker="*")
    puts "**********\n* HERE #{marker.to_s} *\n**********"
  end
end

Object.__send__ :include, TrackerExtensions