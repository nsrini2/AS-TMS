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
    
  end  
end
