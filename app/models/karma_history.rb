class KarmaHistory < ActiveRecord::Base
  class << self    
    def capture_points
      t = Time.new
      sql = <<-EOS
        INSERT INTO karma_histories (profile_id, month, year, value, karma_login)
        (SELECT id, #{t.month}, #{t.year}, karma_points, karma_login_points
        FROM profiles)
        ON DUPLICATE KEY UPDATE value = karma_points, karma_login = karma_login_points
      EOS
      ActiveRecord::Base.connection.execute(sql)
    end
    
    def top_ten_karma_earners_for_month(d = Date.today)
      year = d.year
      month = d.month
      previous_month = d.prev_month.month
      previous_year = d.prev_month.year
      
      # SSJ 2012-09-04 rewrote query and got this down to 10.39 seconds
      sql = <<-EOS
        SELECT profiles.screen_name, profiles.profile_1 as agency_name, profiles.profile_8 as agency_type, karma_earned
        FROM profiles, 
        (SELECT t1.profile_id, (t1.net_karma - t2.net_karma) as karma_earned 
        FROM 
        (SELECT karma_histories.profile_id, 
        (karma_histories.value - karma_histories.karma_login) as net_karma
        FROM karma_histories, `profiles`
        WHERE karma_histories.profile_id = `profiles`.id
        AND profiles.`status` = 1	 
        AND month = #{month} AND year = #{year} ) as t1,

        (SELECT karma_histories.profile_id, 
        (karma_histories.value - karma_histories.karma_login) as net_karma
        FROM karma_histories, `profiles`
        WHERE karma_histories.profile_id = `profiles`.id
        AND profiles.`status` = 1	 
        AND month = #{previous_month} AND year = #{previous_year} ) as t2
        
        WHERE t1.profile_id = t2.profile_id
        ORDER BY karma_earned DESC
        LIMIT 10) as t3
        WHERE t3.profile_id = profiles.id
      EOS
      
      find_by_sql(sql)
    end
  end  
end
