if File.exists?("#{Rails.root}/lib/assist/video/s3_panda.rb")
  require "#{Rails.root}/lib/assist/video/s3_panda"
elsif File.exists?("#{Rails.root}/vendor/plugins/cubeless/lib/assist/video/s3_panda.rb")
  require "#{Rails.root}/vendor/plugins/cubeless/lib/assist/video/s3_panda"
end

class Video < ActiveRecord::Base
  include Assist::Video::S3Panda
  
  belongs_to :profile
  
  acts_as_taggable
  validates_presence_of :profile
  validates_presence_of :tag_list, :message => "^Tags are required"
  validates_length_of :title, :within => 1..250, :too_short => "can't be blank"
  
  named_scope :encoded, { :conditions => ["encoded = ?", true] }
  named_scope :unencoded, { :conditions => ["encoded = ?", false] }
  
  def before_save
    self.tag_list_cache = self.tag_list.to_s
  end
  
  def editable_by?(profile)
    profile.has_role?(Role::ContentAdmin)
  end
  
  class << self
    
    def enabled?
      Config['video_enabled']
    end
    
    def find_by_keywords(query, options={})
      query = "%#{query}%"
      ModelUtil.add_conditions!(options, ["encoded = ? AND (title LIKE ? OR description LIKE ? OR tag_list_cache LIKE ?)", true, query, query, query])
      
      find(:all, options)
    end
    
    def update_encodings
      unencoded.each{ |v| v.check_encoding }
    end
    
  end 
   
end
