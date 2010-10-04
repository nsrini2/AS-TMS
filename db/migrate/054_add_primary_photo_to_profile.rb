class AddPrimaryPhotoToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :primary_photo_id, :integer
    execute "update profiles p join attachments a on a.owner_id=p.id set p.primary_photo_id=a.id"
    add_index :profiles, :primary_photo_id
  end

  def self.down
    remove_column :profiles, :primary_photo_id
  end
end
