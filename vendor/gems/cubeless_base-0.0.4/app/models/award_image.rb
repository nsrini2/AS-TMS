class AwardImage < Attachment

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 2.megabytes,
                 :thumbnails => { :thumb => [35,35], :preview => [60,60], :full => [90,90] }

  validates_as_attachment

end