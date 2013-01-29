class CreatedAtYearMonthForBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :created_at_year_month, :integer
    execute 'update blog_posts set created_at_year_month = year(created_at)*100 + month(created_at)'
    change_column :blog_posts, :created_at_year_month, :integer, :null => false
    add_index :blog_posts, :created_at_year_month
  end

  def self.down
    remove_column :blog_posts, :created_at_year_month
  end
end
