class AddProfilePhoto < ActiveRecord::Migration
  
  def self.up
    add_column :profiles, :profile_photo_id, :integer
  end
  
  def self.down
    remove_column :profiles, :profile_photo_id
  end
  
end