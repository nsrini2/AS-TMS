class ActivityStreamMessage < ActiveRecord::Base
  belongs_to :primary_photo, :class_name => 'ActivityStreamMessagePhoto', :foreign_key => :primary_photo_id
  scope :active, where("#{table_name}.active > 0")
  scope :available, :order => :created_at #should return an ActiveRecord::Relation object
    
  def primary_photo_path(which=:thumb)
    primary_photo.public_filename(which) if !primary_photo.nil?
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
