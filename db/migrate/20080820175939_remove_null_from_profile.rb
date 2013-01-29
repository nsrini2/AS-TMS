class RemoveNullFromProfile < ActiveRecord::Migration
  def self.up
    change_column :profiles, :roles, :string, :null => true
  end

  def self.down
  end
end
