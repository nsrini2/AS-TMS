class CreateRoles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :roles, :string, :null => false
    add_index :profiles, :roles
  end

  def self.down
    remove_column :profiles, :roles
  end
end
