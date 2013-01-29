class AddGalleryPhotoTable < ActiveRecord::Migration
  def self.up
    create_table :gallery_photos do |t|
      t.column :caption, :string
      t.column :views, :integer
      t.column :group_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :gallery_photos
  end
end
