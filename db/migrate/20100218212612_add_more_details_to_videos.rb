class AddMoreDetailsToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :image_url, :string
    add_column :videos, :filename, :string
    add_column :videos, :extname, :string
  end

  def self.down
    remove_column :videos, :image_url
    remove_column :videos, :filename
    remove_column :videos, :extname
  end
end
