class UnsuccessfulLoginAttempts < ActiveRecord::Migration
  def self.up
    add_column :users, :unsuccessful_login_attempts, :integer, :default => 0
    add_column :users, :locked_until, :datetime
  end

  def self.down
    remove_column :users, :locked_until
    remove_column :users, :unsuccessful_login_attempts
  end
end
