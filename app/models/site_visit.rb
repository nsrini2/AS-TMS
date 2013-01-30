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
      visitors_by_range(start_date, start_date + 7)
    end
    
    def visitors_by_month(day = Date.today)
      start_date = day.at_beginning_of_month
      end_date = day.at_end_of_month
      visitors_by_range(start_date, end_date)
    end
    
    def visitors_by_range(start_date, end_date)
      SiteVisit.select("DISTINCT profile_id").where("created_at between ? AND ? ", start_date, end_date+1).count 
    end
    
    def visitors_by_country(start_date, end_date)
      sql = <<-EOS
        SELECT profile_registration_fields.`value` as country, count(site_registration_field_id) as profile_count
        FROM (SELECT DISTINCT profile_id FROM site_visits  WHERE created_at BETWEEN '#{start_date}' AND '#{end_date}') as unique_visits,
        profile_registration_fields
        WHERE unique_visits.profile_id = profile_registration_fields.profile_id
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
