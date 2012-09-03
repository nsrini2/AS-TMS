class KarmaHistory < ActiveRecord::Base
  class << self    
    def capture_points
      t = Time.new
      sql = <<-EOS
        INSERT INTO karma_histories (profile_id, month, year, value)
        (SELECT id, #{t.month}, #{t.year}, karma_points
        FROM profiles)
        ON DUPLICATE KEY UPDATE value = karma_points
      EOS
      ActiveRecord::Base.connection.execute(sql)
    end
    
    def top_ten_karma_earners_for_month(d = Date.today)
      year = d.year
      month = d.month
      previous_month = d.prev_month.month
      previous_year = d.prev_month.year
      sql = <<-EOS
        SELECT profiles.screen_name, profiles.profile_1 as agency_name, profiles.profile_8 as agency_type, (t1.value - t2.value) as karma_earned
        FROM 
        (SELECT * from karma_histories WHERE month = #{month} AND year = #{year} ) as t1,
        (SELECT * from karma_histories WHERE month = #{previous_month} AND year = #{previous_year}) as t2,
        `profiles`
        WHERE t1.profile_id = t2.profile_id
        AND profiles.id = t2.profile_id
        AND profiles.status = 1
        ORDER BY karma_earned DESC
        LIMIT 10
      EOS
      find_by_sql(sql)
    end
  end  
end
