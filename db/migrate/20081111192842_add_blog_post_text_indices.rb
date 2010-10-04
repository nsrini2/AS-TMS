class AddBlogPostTextIndices < ActiveRecord::Migration
  def self.up
    create_table :blog_post_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :blog_post_id, :integer, :null => false
      t.column :title_text, :text
      t.column :text_text, :text
      t.column :cached_tag_list_text, :text
    end
    add_index :blog_post_text_indices, :blog_post_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_blog_post on blog_post_text_indices (title_text, text_text, cached_tag_list_text)"
  end

  def self.down
    drop_table :blog_post_text_indices
  end
end
