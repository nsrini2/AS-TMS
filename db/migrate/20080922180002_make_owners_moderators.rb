class MakeOwnersModerators < ActiveRecord::Migration
  def self.up
    # groups with moderators have the owner set as a moderator too
    execute "update group_memberships gm join groups g on gm.group_id=g.id and gm.profile_id=g.owner_id join (select * from group_memberships where moderator=1) gm2 on gm2.group_id=g.id set gm.moderator=1 where gm.moderator=0"
  end

  def self.down
  end
end
