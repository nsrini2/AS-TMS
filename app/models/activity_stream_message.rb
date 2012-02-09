class ActivityStreamMessage < ActiveRecord::Base
  has_one :activity_stream_message_photo, :as => :owner, :dependent => :destroy
  scope :active, where(:active => 1)
  scope :available, :order => :created_at #should return an ActiveRecord::Relation object
  
  def primary_photo_path(which=:thumb)
    if !activity_stream_message_photo.nil?
      activity_stream_message_photo.public_filename(which) 
    else
      "/images/gen_avatar_large.png"
    end
  end
  
  def owner_path
    owner_link
  end
  
  def event_path
    event_link
  end
  
  def icon_path
    "/images/icons/as/ticket.png"
  end
  
  def who
    title
  end
  
  def what
    description
  end
  
  def when
    subline
  end
  
  def toggle_activation
     toggle!(:active)
  end  
end
