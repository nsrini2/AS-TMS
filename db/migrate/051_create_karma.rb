class CreateKarma < ActiveRecord::Migration

  def self.up
    add_column :profiles, :karma_points, :integer, :null => false, :default => 0
    add_column :profiles, :karma_login_points, :integer, :null => false, :default => 0
    add_column :profiles, :completed_once, :boolean, :null => false, :default => false
    add_column :profiles, :last_login_date, :date
    add_index :profiles, :karma_points
    #Profile.recalculate_all_karma # deprecated
  end

  def self.down
    remove_column :profiles, :karma_points
    remove_column :profiles, :karma_login_points
    remove_column :profiles, :completed_once
    remove_column :profiles, :last_login_date
  end

end
