class AlterCommentsAddColumnActive < ActiveRecord::Migration
  def self.up
    add_column :comments, :active, :boolean, :default => true
  end

  def self.down
    remove_column :comments, :active
  end
end
