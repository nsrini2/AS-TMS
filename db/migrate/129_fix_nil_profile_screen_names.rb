class FixNilProfileScreenNames < ActiveRecord::Migration

  def self.up
    execute "update profiles set screen_name='a former member' where screen_name is null"
    change_column :profiles, :screen_name, :string, :null => false
  end

  def self.down
    change_column :profiles, :screen_name, :string, :null => true
  end

end
