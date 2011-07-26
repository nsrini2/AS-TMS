class CompanyPhoto < Attachment

  has_attachment :content_type => :image,
               :storage => :file_system,
               :max_size => 5.megabytes,
               :thumbnails => { :thumb => [50,50], :thumb_large => [175,175], :thumb_80 => [80,80] }

  has_one :company, :foreign_key => :primary_photo_id, :dependent => :nullify

  validates_as_attachment
  
  def is_primary?
    self.company
  end
end