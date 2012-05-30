# This tracks the number of unique visitors to our site each day
class SiteVisit < ActiveRecord::Base
  validates :profile_id, :uniqueness => {:scope => :julian_date}
  
  class << self
    def track(profile)
      today_jd = Date.today.jd
      visit = SiteVisit.find_or_create_by_profile_id_and_julian_date(:profile_id => profile.id, :julian_date => today_jd )
    end
    
    def visitors(opts = {})
      today_jd = Date.today.jd
      opts = {:days_ago => 1}.merge!(opts)
      SiteVisit.where(:julian_date => (today_jd - opts[:days_ago]) ).count
    end
    
    def weekly_visitors(opts = {})
      today_jd = Date.today.jd
      (1..7).map do |day|
        date = Date.jd(today_jd - day).strftime("%Y-%m-%d")
        daily_visits = visitors(:days_ago => day)
        "#{date}, #{daily_visits}"
      end
    end
  end  
end
