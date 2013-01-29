class RenameUsersScreenNameToLoginAndAddScreenNameToProfiles < ActiveRecord::Migration
  def self.up
		
		add_column :profiles, :screen_name, :string
		execute 'update profiles p join users u on u.id=p.user_id set p.screen_name=u.screen_name'

		change_column :users, :screen_name, :string, :null => true
		execute 'update users set screen_name=null, crypted_password=null, salt=null where external_id is not null'		
		remove_index :users, :screen_name

		rename_column :users, :screen_name, :login
		add_index :users, :login
		
  end

  def self.down
		
		remove_index :users, :login
		rename_column :users, :login, :screen_name
		add_index :users, :screen_name
		
		execute 'update users u join profiles p on u.id=p.user_id set u.screen_name=p.screen_name where external_id is not null'		
		change_column :users, :screen_name, :string, :null => false
		
		remove_column :profiles, :screen_name
		
  end
end
