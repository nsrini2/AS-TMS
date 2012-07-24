# This tracks the number of unique visitors to our site each day
class SiteVisit < ActiveRecord::Base
  validates :profile_id, :uniqueness => {:scope => :julian_date}
  
  class << self
    def track(profile)
      today_jd = Date.today.jd
      visit = SiteVisit.find_or_create_by_profile_id_and_julian_date(:profile_id => profile.id, :julian_date => today_jd )
    end
    
    def visitors_by_week(day = Date.today)
      start_date = day.at_beginning_of_week
      end_date = start_date + 7
      SiteVisit.select("DISTINCT profile_id").where("created_at between ? AND ? ", start_date, end_date).count 
    end
    
    # def visitors(opts = {})
    #   today_jd = Date.today.jd
    #   opts = {:days_ago => 1}.merge!(opts)
    #   SiteVisit.where(:julian_date => (today_jd - opts[:days_ago]) ).count
    # end
    # 
    # def weekly_visitors(opts = {})
    #   today_jd = Date.today.jd
    #   (1..7).map do |day|
    #     date = Date.jd(today_jd - day).strftime("%Y-%m-%d")
    #     daily_visits = visitors(:days_ago => day)
    #     "#{date}, #{daily_visits}"
    #   end
    # end
    # 
    def visitors_by_country(start_date, end_date)
      sql = <<-EOS
      SELECT profile_registration_fields.`value` as country, count(site_registration_field_id) as profile_count
      FROM site_visits, profile_registration_fields
      WHERE site_visits.profile_id = profile_registration_fields.profile_id
      AND site_visits.created_at BETWEEN '#{start_date}' AND '#{end_date}'
      AND site_registration_field_id = 4
      GROUP BY profile_registration_fields.`value`
      ORDER BY profile_count DESC
      LIMIT 10
      EOS
      find_by_sql(sql)
    end

    
    def active_profiles_by_country
      sql = <<-EOS
      SELECT profile_registration_fields.`value` as country, count(site_registration_field_id) as profile_count
      FROM profiles, profile_registration_fields
      WHERE profiles.id = profile_registration_fields.profile_id
      AND profiles.status = 1
      AND site_registration_field_id = 4
      GROUP BY profile_registration_fields.`value`
      ORDER BY country
      EOS
      find_by_sql(sql)
    end
    
  end  
end
