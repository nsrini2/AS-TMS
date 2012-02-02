class ActivityStreamMessage < ActiveRecord::Base
  has_one :activity_stream_message_photo, :as => :owner, :dependent => :destroy
  
  def path
    "/"
  end
  
  def icon
    "/"
  end
  
  def who
    "title"
  end
  
  def what
    "descriptin"
  end
  
  def when
    Time.now()
  end
end
