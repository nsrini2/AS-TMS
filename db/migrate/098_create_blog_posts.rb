class CreateBlogPosts < ActiveRecord::Migration
  def self.up
  	create_table :blog_posts do |t|
  		t.column :created_at,	:datetime, :null => false
			t.column :updated_at,	:datetime, :null => false
  		t.column :blog_id,		:integer, :null => false
  		t.column :profile_id,	:integer, :null => false
  		t.column :title,			:string, :null => false
			t.column :text,				:text, :null => false
  	end
  end

  def self.down
  	drop_table :blog_posts
  end
end
