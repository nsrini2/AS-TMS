class RemoveKarmaTimeout < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :karma_timeout
  end

  def self.down
    add_column :profiles, :karma_timeout, :integer, :null => false, :default => 0
  end
end
