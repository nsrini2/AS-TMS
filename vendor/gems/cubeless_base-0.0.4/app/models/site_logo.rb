class SiteLogo < Attachment
  include Config::Callbacks

  has_attachment :content_type => :image,
               :storage => :file_system,
               :max_size => 5.megabytes,
               :resize_to => '300x60>'
               
               # :thumbnails => { :thumb => [50,50], :thumb_large => [175,175], :thumb_80 => [80,80] }

  validates_as_attachment

end