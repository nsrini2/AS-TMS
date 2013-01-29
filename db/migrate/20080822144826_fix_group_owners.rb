class FixGroupOwners < ActiveRecord::Migration
  def self.up
    execute("update groups set owner_id=(select profile_id from (select * from group_memberships order by created_at) as a where group_id=groups.id group by group_id)")
  end

  def self.down
    #no down
  end
end
