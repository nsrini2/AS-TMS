class MarketingImage < Attachment

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 5.megabytes,
                 :thumbnails => { :large => [395,146], :thumbnail => [119,44] }

  validates_as_attachment

end