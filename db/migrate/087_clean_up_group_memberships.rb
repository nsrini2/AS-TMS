class CleanUpGroupMemberships < ActiveRecord::Migration
  def self.up
    execute 'update groups set group_memberships_count = (select count(1) from group_memberships where group_id = groups.id)'
  end

  def self.down
  end
end
