module TrackerExtensions
  # SSJ: method to track code happenings...
  def here(marker="******")
    if marker.respond_to? :length
      num = marker.length
    else
      num = 50
    end    
    h = "**"
    num.to_i.times do 
      h << "*"
    end
    h << "\n"
    puts h
    puts " #{marker} "
    puts h
      
  end
end

Object.__send__ :include, TrackerExtensions