class CreatePosts < ActiveRecord::Migration
  def self.up
  	create_table :posts do |t|
  		t.column :created_at,	:datetime, :null => false
  		t.column :group_id,		:integer, :null => false
  		t.column :profile_id,	:integer, :null => false
  		t.column :message,		:string, :null => false
  	end
  end

  def self.down
  	drop_table :posts
  end
end
