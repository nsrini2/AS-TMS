class AddDeFlagToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :de_flag, :integer
  end

  def self.down
    remove_column :groups, :de_flag
  end
end
