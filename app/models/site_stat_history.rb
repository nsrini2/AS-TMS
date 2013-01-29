class SiteStatHistory < ActiveRecord::Base
  class << self
    def capture_daily_stats
      capture_stat('active_members', Profile.active.count)
    end
    
        
    def capture_stat(name, value)
      find_or_create_by_name_and_julian_date(:name => name, :julian_date => Date.today.jd, :value => value )
    end
    
    def stat_by_week(stat, day = Date.today)
      start_date = day.at_beginning_of_week
      self.where(:name => stat).where(:created_at => start_date).value 
      rescue NoMethodError
        0
    end
    
  end
end
