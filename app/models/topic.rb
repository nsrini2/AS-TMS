require "#{Rails.root}/vendor/plugins/live_qa/app/models/topic"

class Topic

  def after_save
    unless self.chat && self.chat.on_air?
      # process the indexing in dalay job
      ChatTopicIndex.delay.update_indices(self)
    end
  end
  
end  