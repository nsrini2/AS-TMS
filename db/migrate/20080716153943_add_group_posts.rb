class AddGroupPosts < ActiveRecord::Migration
  def self.up
    create_table :group_posts do |t|
      t.text :post, :null => false
      t.references :group, :profile
      t.timestamps
    end
    add_index :group_posts, :group_id
    add_index :group_posts, :profile_id
    add_index :group_posts, :created_at
  end

  def self.down
    drop_table :group_posts
  end
end
