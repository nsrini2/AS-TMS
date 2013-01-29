class UpdateProfileAndProfilePhotoForMultiplePhotos < ActiveRecord::Migration
  def self.up
    add_column :attachments, :owner_id, :integer
    add_column :attachments, :owner_type, :string

    execute "update attachments a join profiles p on a.id=p.profile_photo_id set a.owner_type='Profile', a.owner_id=p.id"

    remove_column :profiles, :profile_photo_id
  end

  def self.down
    add_column :profiles, :profile_photo_id, :integer
    # for immediate rollback only --- otherwise last image uploaded will be the primary
    execute "update profiles p join attachments a on a.owner_id=p.id set p.profile_photo_id=a.id"
    add_index :profiles, :profile_photo_id
    
    remove_column :attachments, :owner_id
    remove_column :attachments, :owner_type
  end
end
