class ChatTopicIndex < ActiveRecord::Base
  belongs_to :topic
  validates_presence_of :chat_title_text
  
  # don't auto escape HTML characters from this model
  xss_terminate :except => self.column_names
  
  def text_index_prep(text, exclude_terms_set=nil, remove_weak_terms=true)
    #SSJ 2010-02-24 This method is just a hook to allow for easy integreation into Cubeless environments
    return text
  end

  class << self
  
    def update_indices(topic)
      # SSJ 10-18-2012 Delayed::Job runs every 15 mins, so if a topic gets deleted before the DJ has run
      # the DJ will get an error trying to update an index that does not exist
      # so make sure it exists before running
      return unless topic
      topic_index = ChatTopicIndex.find_or_create_by_topic_id(topic.id)
      topic_index.chat_title_text = topic_index.text_index_prep(topic.chat.title, "", false)
      topic_index.topic_text = topic_index.text_index_prep(topic.title, "", false)
      topic_index.posts_text = topic_index.text_index_prep((topic.posts.collect {|post| post.body}).join(" "))
      topic_index.save!
    end
  
    def find_by_keywords(search_text, options={})
      # SSJ This is a hook to integrate search results calculate your search requirements here
      Topic.find(:all)
    end
  
  end  
  
end
