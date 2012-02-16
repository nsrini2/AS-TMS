require "#{Rails.root}/vendor/plugins/live_qa/app/models/topic"

class Topic
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  
  after_save :update_indexes, :stream_to_activity
  
  def update_indexes
    #if the chat is inactive, Topic won't find it
    if self.chat  
      # process the indexing in dalay job
      ChatTopicIndex.delay.update_indices(self) unless self.chat.on_air?
    else
      chat_topic_index.delay.destroy if chat_topic_index
    end
  end
  
  def stream_to_activity
    if self.status_was == "open" && self.status == "active"
      ActivityStreamEvent.add(self.class,self.id,:create, {})
    end  
  end

# ACTIVITY STREAM INTERFACE ELEMENTS 
  def primary_photo_path(which=:thumb)
    chat.primary_photo_path(which)
  end
  
  def owner_path
    chat_path(chat)
  end
  
  def event_path
    owner_path
  end
  
  def icon_path
    "/images/icons/as/chat.png"
  end
  
  def who
    chat.title
  end
  
  def what
    self.title
  end
  
  def when
    "#{time_ago_in_words(updated_at)} ago"
  end
end  