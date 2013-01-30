class AddKarmaLoginToHistory < ActiveRecord::Migration
  def self.up
  	add_column :karma_histories, :karma_login, :integer, :default => 0
  end

  def self.down
  	remove_column :karma_histories, :karma_login
  end
end
