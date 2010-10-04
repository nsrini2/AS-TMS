class AddKarmaTimeout < ActiveRecord::Migration

  def self.up
    add_column :profiles, :karma_timeout, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :profiles, :karma_timeout
  end

end
