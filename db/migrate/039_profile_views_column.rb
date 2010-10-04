class ProfileViewsColumn < ActiveRecord::Migration
  def self.up
    add_column :profiles, :profile_views, :integer, :default => 0
    add_index :profiles, :profile_views
  end

  def self.down
    remove_column :profiles, :profile_views
  end
end
