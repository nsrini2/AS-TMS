class GalleryPhotoAttachment < Attachment

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 5.megabytes,
                 :resize_to => "460x>",
                 :thumbnails => { :small_thumb => [90,90], :thumb => [140,105], :preview => [300,220], :full => [460,345] }

  validates_as_attachment 

  def self.regenerate_thumbnails
    self.all.select {|p| p.thumbnails.size <= 1 }.each do |p|
      puts "Regenerating thumbnails for #{p.filename}"
      begin
        temp_file = p.create_temp_file
      rescue
        puts "Failed to create temp file for #{p.id}"
        nil
      end
      p.attachment_options[:thumbnails].each { |suffix, size|
        begin
          p.create_or_update_thumbnail(temp_file, suffix, *size)
        rescue
          puts "Failed to process #{p.id}"
          nil
        end
      }
    end
  end
  
  # SSJ -- FIX This causes code to break in 3.0.10, not sure what its purpose is, so I did not delete
  # def thumbnail(which)
  #   thumbnails.find_by_thumbnail(which)
  # end
end