class GroupPhoto < Attachment

  has_attachment :content_type => :image,
               :storage => :file_system,
               :max_size => 5.megabytes,
               :thumbnails => { :thumb_small => [30,30], :thumb => [50,50], :thumb_large => [175,175], :thumb_80 => [80,80] }

  has_one :group, :foreign_key => :primary_photo_id, :dependent => :nullify

 
  #stream_to :activity
  validates_as_attachment

end
