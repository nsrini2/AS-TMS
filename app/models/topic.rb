require "#{Rails.root}/vendor/plugins/live_qa/app/models/topic"

class Topic < ActiveRecord::Base

  def after_save
    # process the indexing in dalay job
    ChatTopicIndex.delay.update_indices(self)
  end
  
end  