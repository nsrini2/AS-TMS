class SetStartingMonthKarma < ActiveRecord::Migration
  def self.up
    t = Time.parse("2012-06-01")
    sql = <<-EOS
      INSERT INTO karma_histories (profile_id, month, year, value)
      (SELECT id, #{t.month}, #{t.year}, 0
      FROM profiles)
      ON DUPLICATE KEY UPDATE value = 0
    EOS
    puts sql
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
  end
end
