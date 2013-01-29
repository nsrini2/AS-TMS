class AddTempUserIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :temp_user_id, :integer
  end

  def self.down
    remove_column :reviews, :temp_user_id
  end
end
