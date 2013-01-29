class RemovePostAbuses < ActiveRecord::Migration
  
  def self.up
    execute "delete from abuses where abuseable_type='Post'"
  end

  def self.down
  end
end
