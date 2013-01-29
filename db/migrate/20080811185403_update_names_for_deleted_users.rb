class UpdateNamesForDeletedUsers < ActiveRecord::Migration
  def self.up
    execute "update profiles set first_name='default_first' where status = -2 "
    execute "update profiles set last_name='default_last' where status = -2 "
  end

  def self.down
  end
end
