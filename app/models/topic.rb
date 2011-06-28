require "#{Rails.root}/vendor/plugins/live_qa/app/models/topic"

class Topic

  def after_save
    #if the chat is inactive, Topic won't find it
    if self.chat  
      # process the indexing in dalay job
      ChatTopicIndex.delay.update_indices(self) unless self.chat.on_air?
    else
      chat_topic_index.delay.destroy  
    end
  end
  
end  