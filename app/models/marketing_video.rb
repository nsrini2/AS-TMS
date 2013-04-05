class MarketingVideo < Attachment

   has_attachment :content_type => :video,
                 :storage => :file_system,
                 :max_size => 500.megabytes,
                 :thumbnails => { :large => [595,220], :thumbnail => [119,44] }

   validates_as_attachment
end
