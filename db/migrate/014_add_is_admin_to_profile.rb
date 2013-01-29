class AddIsAdminToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :is_admin, :boolean
  end

  def self.down
    remove_column :profiles, :is_admin
  end
end
