class GenericAttachment < Attachment
  has_attachment :storage => :file_system
end