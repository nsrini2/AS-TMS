class AddEncodedToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :encoded, :boolean, :default => false
  end

  def self.down
    remove_column :videos, :encoded
  end
end
