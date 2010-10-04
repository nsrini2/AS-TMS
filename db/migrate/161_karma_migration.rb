class KarmaMigration < ActiveRecord::Migration

  def self.up
    add_column :profiles, :old_karma_points, :integer
    execute 'update profiles set old_karma_points = karma_points'
    KarmaObserver.recalc_karma!
  end

  def self.down
    raise 'cant go back'
  end

end
