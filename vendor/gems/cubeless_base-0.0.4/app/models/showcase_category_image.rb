class ShowcaseCategoryImage < Attachment

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 5.megabytes,
                 :thumbnails => { :medium => [200, 250], :thumb => [35,35], :preview => [60,60] }

  def validate
    errors.add_to_base("Filename is blank") if self.filename == nil
    errors.add_to_base("Please attach an image file (.jpeg, .gif) only") if !self.image?
  end

end
