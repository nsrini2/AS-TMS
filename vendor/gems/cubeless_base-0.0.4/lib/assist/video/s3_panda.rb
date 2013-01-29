require 's3'
require 'getthere_integration' # This is needed for the xml utils

module Assist::Video::S3Panda
  include XmlUtils

  def public_s3_image_url
    "https://s3.amazonaws.com/#{bucket}/" + filename + "_1.jpg"#".flv_50.jpg" #"_1.jpg"
  end
  
  def private_s3_image_url
    "#{public_s3_image_url}?AWSAccessKeyId=#{akid}&Signature=#{signature_photo}&Expires=#{s3_expiration}"
  end
  
  def s3_image_url
    private_s3_image_url
  end
  
  def public_s3_url
    "https://s3.amazonaws.com/#{bucket}/" + filename + extname
  end
  
  def private_s3_url        
    "#{public_s3_url}?AWSAccessKeyId=#{akid}&Signature=#{signature}&Expires=#{s3_expiration}"
  end
  
  def image_url
    # i = self[:image_url] 
    # if i.blank?
    #   i = s3_image_url
    #   self.update_attribute(:image_url, i)      
    # end
    # i.to_s
    s3_image_url
  end
  
  def filename
    f = self.attributes[:filename]
    if f.blank?
      f = encoding_data['id']
      self.update_attribute(:filename, f)      
    end
    f.to_s
  end
  
  def extname
    e = self.attributes[:extname]
    if e.blank?
      e = encoding_data['extname']
      self.update_attribute(:extname, e)
    end
    e.to_s
  end
  
  def encoded
    e = self.attributes[:encoded]
    if !e
      e = (encoding_data['status'].to_s == "success")
      self.update_attribute(:encoded, e) if e
    end
    e
  end
  alias_method :check_encoding, :encoded
  
  def encoding_status
    if encoded 
      "success"
    else
      encoding_data['status']
    end
  end
  
  def encoding_data
    begin
      @encoding_data ||= JSON.parse(
        Panda.get("/videos/#{panda_video_id}/encodings.json").body
      ).first
    rescue
      Rails.logger.fatal "Problem pulling encoding data for video with ID:#{id} and PANDA_ID:#{panda_video_id}"
      {}
    end
    
    # @encoding_data ||= convert_xml_to_encoding_data
  end
  
  def convert_xml_to_encoding_data
    xml = RestClient.get "#{PANDA_URL}/videos/#{panda_video_id}.xml?account_key=SECRET_KEY_FOR_PANDA_API"
    xml_doc = REXML::Document.new(xml.body).root
    
    encodings = []
    REXML::XPath.each(xml_doc,"encodings/video") { |e| encodings << e }
    
    xml_id = find_first(encodings.first.to_s, "id")
    xml_filename = find_first(encodings.first.to_s, "filename")


    { 'id' => xml_id,
      'filename' => xml_filename.split(".").first, 
      'extname' => "." + xml_filename.split(".").last.to_s }
  end
  
  private
  
  def bucket
    # "cubeless_video_test"
    # "s3hub-7c4f2edfce6c25c353f210580e697b968888698b6184d8c20231ab725"
    "cubeless-pandastream-2"
  end
  
  def resource
    # encoding_data['id'] + encoding_data['extname']
    filename.to_s + extname.to_s
  end
  
  def s3_expiration
    Time.now.strftime("%s").to_s.to_i + 100 # 5
  end
  
  def signature
    S3::Signature.generate_temporary_url_signature(:bucket => bucket,
                                                   :resource => resource,
                                                   :secret_access_key => sakid,
                                                   :expires_on => s3_expiration)    
  end
  
  def resource_photo
    filename + "_1.jpg" # ".flv_50.jpg"
  end
  
  def signature_photo
    S3::Signature.generate_temporary_url_signature(:bucket => bucket,
                                                   :resource => resource_photo,
                                                   :secret_access_key => sakid,
                                                   :expires_on => s3_expiration)    
  end
  
  # MM2: The panda secret/access keys are not really working.
  # Only our original ones are working
  def akid
    "AKIAJZI3IOEAO3L7QXNA" 
    # Panda.access_key
  end
  def sakid
    "ybRHnDVgUMH9xIT5VZgmvFWHehQCg3VeYid8Tfp8"
    # Panda.secret_key
  end
end