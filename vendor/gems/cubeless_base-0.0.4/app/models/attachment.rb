class Attachment < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  def photo_error
    if self.class.class_variable_defined?(:@@photo_error)
      self.class.__send__(:class_variable_get, :@@photo_error)
    else
      max_size = (self.class.attachment_options[:max_size] / (1024.0 * 1024.0)).to_i
      error = "Image must be less than #{max_size}MB and of type JPEG/JPG, GIF, or PNG"
      self.class.__send__(:class_variable_set, :@@photo_error, error)
    end
  end

  def self.generate_photo_path(primary_photo_id,filename,thumbnail=nil)
    primary_photo_id = primary_photo_id.to_i
    filename = filename.sub('.',"_#{thumbnail.to_s}.") if thumbnail
    id1 = primary_photo_id/10000
    id2 = primary_photo_id%10000
    "/attachments/#{id1.to_s.rjust(4,'0')}/#{id2.to_s.rjust(4,'0')}/#{filename}"
  end

  def copy(clazz=self.class)
    clazz.new(:content_type => self.content_type, :filename => self.filename, :temp_path => self.full_filename)
  end

  def copy!(clazz=self.class)
    tmp = copy(clazz)
    tmp.save!
    tmp
  end

  def after_validation
    has_errors = self.errors.size > 0
    if has_errors
      self.errors.clear
      self.errors.add_to_base(photo_error)
    end
  end

end
