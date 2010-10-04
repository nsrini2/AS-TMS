class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :author_id,  :integer, :null => false
      t.column :blog_post_id, :integer, :null => false
      t.column :text, :string, :limit => 4000, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :comments, :author_id
    add_index :comments, :blog_post_id
    add_column :blog_posts, :comments_count, :integer
  end

  def self.down
    drop_table :comments
    remove_column :blog_posts, :comments_count
  end
end