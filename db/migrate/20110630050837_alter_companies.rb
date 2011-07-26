class AlterCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :description, :text
    add_column :companies, :owner_id, :integer
    add_column :companies, :primary_photo_id, :integer
    add_column :companies, :active, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :companies, :description
    remove_column :companies, :owner_id
    remove_column :companies, :primary_photo_id
    remove_column :companies, :active
  end
end
