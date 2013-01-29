class SplitProfileStatus < ActiveRecord::Migration

  def self.up
    add_column :profiles, :visible, :boolean, :null => false, :default => true
    execute 'update profiles set visible=0 where status<=0'
    execute 'update profiles set status=status-1 where status<=0'
    execute 'update profiles set status=0 where status=2'
    add_index :profiles, :visible
  end

  def self.down
    execute 'update profiles set status=1 where status=2' # pending users become active
    execute 'update profiles set status=2 where status=0' # on leave
    execute 'update profiles set status=status+1 where status<0'
    remove_column :profiles, :visible
  end

end
