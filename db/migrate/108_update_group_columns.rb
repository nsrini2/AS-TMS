class UpdateGroupColumns < ActiveRecord::Migration
  def self.up
    change_column :groups, :description, :string, :limit => 500, :null => false
    change_column :groups, :tags, :string, :limit => 300, :null => false
  end

  def self.down
  end
end
