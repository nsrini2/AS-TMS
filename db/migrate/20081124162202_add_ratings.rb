class AddRatings < ActiveRecord::Migration
  def self.up
    add_column :gallery_photos, :rating_count, :integer, :null => false, :default => 0
    add_column :gallery_photos, :rating_total, :integer, :null => false, :default => 0
    add_column :gallery_photos, :rating_avg,   :decimal, :precision => 10, :scale => 2, :null => false, :default => 0
  end

  def self.down
    remove_column :gallery_photos, :rating_count
    remove_column :gallery_photos, :rating_total
    remove_column :gallery_photos, :rating_avg
  end
end
