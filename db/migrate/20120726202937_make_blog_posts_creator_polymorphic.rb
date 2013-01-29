class MakeBlogPostsCreatorPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :blog_posts, :profile_id, :creator_id
    add_column :blog_posts, :creator_type, :string
    sql = <<-EOS
      UPDATE blog_posts SET creator_type = 'Profile'
    EOS
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
    rename_column :blog_posts, :creator_id, :profile_id
    remove_column :blog_posts, :creator, :string
  end
  
end
