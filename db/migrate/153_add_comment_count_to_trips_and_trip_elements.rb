class AddCommentCountToTripsAndTripElements < ActiveRecord::Migration
  def self.up
    add_column :trips, :comments_count, :integer, :null => false, :default => 0
    add_column :trip_elements, :comments_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :trips, :comments_count
    remove_column :trip_elements, :comments_count
  end
end
