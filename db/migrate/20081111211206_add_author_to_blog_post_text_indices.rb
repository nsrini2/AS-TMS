class AddAuthorToBlogPostTextIndices < ActiveRecord::Migration
  def self.up
    add_column :blog_post_text_indices, :author, :text
    execute "ALTER TABLE blog_post_text_indices DROP INDEX fulltext_blog_post"
    execute "CREATE FULLTEXT INDEX fulltext_blog_post on blog_post_text_indices (title_text, text_text, cached_tag_list_text, author)"
  end

  def self.down
    remove_column :blog_post_text_indices, :author
    execute "ALTER TABLE blog_post_text_indices DROP INDEX fulltext_blog_post"
    execute "CREATE FULLTEXT INDEX fulltext_blog_post on blog_post_text_indices (title_text, text_text, cached_tag_list_text)"
  end
end
