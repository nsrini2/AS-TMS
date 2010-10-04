class AddLastViewByAuthor < ActiveRecord::Migration
  def self.up
    add_column :questions, :viewed_at, :datetime, :default => 0
  end

  def self.down
    remove_column :questions, :viewed_at
  end
end
