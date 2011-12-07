class CreateChatTopicIndices < ActiveRecord::Migration
  def self.up
    create_table :chat_topic_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :topic_id, :integer, :null => false
      t.column :chat_title_text, :text
      t.column :topic_text, :text
      t.column :posts_text, :text
      t.timestamps
    end
    
    add_index :chat_topic_indices, :topic_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_topic on chat_topic_indices (chat_title_text, topic_text)"
    execute "CREATE FULLTEXT INDEX fulltext_post_topics on chat_topic_indices (topic_text)"
    execute "CREATE FULLTEXT INDEX fulltext_topic_posts on chat_topic_indices (posts_text)"
    
  end

  def self.down
    drop_table :chat_topic_indices
  end
end
