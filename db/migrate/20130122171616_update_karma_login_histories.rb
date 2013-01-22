class UpdateKarmaLoginHistories < ActiveRecord::Migration
  def self.up
  	sql = <<-EOS
      UPDATE karma_histories 
      SET karma_login = value
    EOS
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
  	sql = <<-EOS
      UPDATE karma_histories 
      SET karma_login = 0
    EOS
    ActiveRecord::Base.connection.execute(sql)
  end
end
