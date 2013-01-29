module UsersHelper
  def sort_link_helper(text, param)
    key = param
    key += "_reverse" if params[:sort] == param
    link_to(text, url_for(params.merge({:sort => key, :page => nil})), :title => "Sort by this field")
  end

  def late_msg(msg)
   "<span class='late'>" + msg + "</span>"
  end
  
  def recent_date?(date)
    !date.nil? && date > (Time.now - 24.hours)
  end
  
  def resent_status(date)
    status =  if date.nil?
                "User Never Logged In"
              elsif recent_date?(date)
                late_msg("< 24hrs Ago")
              else
                short_date(date)
              end
  end
  
  def enableCBox(date, value, i)
    enabler = if recent_date?(date)
                "DISABLED name='' value='Welcome Sent < 24 Hours Ago'" 
              else
                "name='sendcbToggle[" + i + "]' " + "value='" + value.to_s + "'" 
              end
    "<input type='checkbox' " + enabler + " /> "      
  end
end














