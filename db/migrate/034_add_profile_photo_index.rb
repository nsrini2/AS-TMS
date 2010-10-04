class AddProfilePhotoIndex < ActiveRecord::Migration

  def self.up
  	add_index :profiles, :profile_photo_id  	
  end
  
  def self.down
  	remove_index :profiles, :profile_photo_id  	
  end

end