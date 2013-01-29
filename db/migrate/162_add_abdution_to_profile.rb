class AddAbdutionToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :karma_abducted, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :profiles, :karma_abducted
  end
end
