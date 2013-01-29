class SiteFavicon < Attachment
  include Config::Callbacks


  has_attachment :content_type => ['image/vnd.microsoft.icon','image/ico','image/icon','text/ico','application/ico','image/x-icon'],
               :storage => :file_system,
               :max_size => 2.megabytes,
               :resize_to => '16x16'
               
               # :thumbnails => { :thumb => [50,50], :thumb_large => [175,175], :thumb_80 => [80,80] }
  # TODO: validate .ico files
  # validates_as_attachment

end