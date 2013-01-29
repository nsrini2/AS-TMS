class AddUserIdToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :user_id, :integer
  end

  def self.down
  end
end
