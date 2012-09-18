class CreateNewsFollowers < ActiveRecord::Migration
  def self.up
    create_table :news_followers do |t|
      t.integer :profile_id
      t.timestamps
    end
  end

  def self.down
    drop_table :news_followers
  end
end
