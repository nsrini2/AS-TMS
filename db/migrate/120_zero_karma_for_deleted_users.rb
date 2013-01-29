class ZeroKarmaForDeletedUsers < ActiveRecord::Migration

  def self.up
    execute 'update profiles set karma_points=0 where status=-2'
  end

  def self.down
  end

end
