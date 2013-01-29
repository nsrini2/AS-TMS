class AddBlogsForExistingGroupsAndProfiles < ActiveRecord::Migration
  def self.up
		execute "INSERT INTO blogs (created_at, updated_at, owner_id, owner_type) SELECT current_timestamp(),current_timestamp(),profiles.id,'Profile' FROM profiles left join blogs on owner_type='Profile' and owner_id=profiles.id where blogs.id is null"
		execute "INSERT INTO blogs (created_at, updated_at, owner_id, owner_type) SELECT current_timestamp(),current_timestamp(),groups.id,'Group' FROM groups left join blogs on owner_type='Group' and owner_id=groups.id where blogs.id is null"
		add_index :blogs, [:owner_type, :owner_id], :unique => true
	end
	
	def self.down
		remove_index :blogs, [:owner_type, :owner_id]
	end
end