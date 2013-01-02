class AddCommentsToPosts < ActiveRecord::Migration

  def self.up
    rename_column :comments, :blog_post_id, :owner_id
    add_column :comments, :owner_type, :string
    # add_column :posts, :comments_count, :integer, :null => false, :default => 0
    add_index :comments, [:owner_type, :owner_id]
    execute "update comments set owner_type='BlogPost'"
  end

  def self.down
    remove_index :comments, [:owner_type, :owner_id]
    # remove_column :posts, :comments_count
    remove_column :comments, :owner_type
    rename_column :comments, :owner_id, :blog_post_id
  end

end