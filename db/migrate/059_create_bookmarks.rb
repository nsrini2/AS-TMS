class CreateBookmarks < ActiveRecord::Migration
  def self.up
      create_table :bookmarks do |t|
      t.column :created_at, :datetime
      t.column :question_id, :integer
      t.column :profile_id, :integer
    end
  end

  def self.down
     drop_table :bookmarks
  end
end