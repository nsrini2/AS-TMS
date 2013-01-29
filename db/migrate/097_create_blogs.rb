class CreateBlogs < ActiveRecord::Migration
  def self.up
  	create_table :blogs do |t|
  		t.column :created_at,				:datetime, :null => false
  		t.column :updated_at,				:datetime, :null => false
  		t.column :owner_id,					:integer, :null => false
  		t.column :owner_type,				:string, :null => false
			t.column :blog_posts_count,	:integer, :null => false, :default => 0
  	end
  end

  def self.down
  	drop_table :blogs
  end
end
