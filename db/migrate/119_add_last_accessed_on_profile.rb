class AddLastAccessedOnProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :last_accessed, :datetime
    add_index :profiles, :last_accessed
  end

  def self.down
    remove_column :profiles, :last_accessed
  end
end