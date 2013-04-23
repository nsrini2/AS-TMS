class AddBoothTwitterIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :booth_twitter_id, :string
  end

  def self.down
    remove_column :groups, :booth_twitter_id
  end
end
