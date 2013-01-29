class MakeFirstLastNonNull < ActiveRecord::Migration

  def self.up
    execute "update profiles set first_name='default_first' where first_name is null"
    execute "update profiles set last_name='default_last' where last_name is null"
    change_column :profiles, :first_name, :string, :null => false
    change_column :profiles, :last_name, :string, :null => false
  end

  def self.down
    change_column :profiles, :first_name, :string, :null => true
    change_column :profiles, :last_name, :string, :null => true
  end

end
