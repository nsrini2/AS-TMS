class AlterChatTopicIndices < ActiveRecord::Migration
  def self.up
    execute "DROP INDEX fulltext_topic on chat_topic_indices"
    execute "CREATE FULLTEXT INDEX fulltext_topic on chat_topic_indices (chat_title_text, topic_text, posts_text)"
  end
  
    

  def self.down
    execute "DROP INDEX fulltext_topic on chat_topic_indices"
    execute "CREATE FULLTEXT INDEX fulltext_topic on chat_topic_indices (chat_title_text, topic_text)"
  end
  
end
