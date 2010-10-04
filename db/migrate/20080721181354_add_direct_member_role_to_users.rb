class AddDirectMemberRoleToUsers < ActiveRecord::Migration
  def self.up
    execute "update profiles p set p.roles = '5' where p.roles = '';"
  end

  def self.down
    execute "update profile p set p.roles = '' where p.roles = '5'"
  end
end
