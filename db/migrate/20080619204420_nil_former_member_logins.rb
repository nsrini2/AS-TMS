class NilFormerMemberLogins < ActiveRecord::Migration
  
  def self.up
    execute "update users set login=null where login='a former member'"
  end

  def self.down
  end

end
