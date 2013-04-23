class ShowcaseCategoryImage < Attachment

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 5.megabytes,
                 :thumbnails => { :large => [350, 100], :thumb => [35,35], :preview => [60,60] }

  validates_as_attachment

end
