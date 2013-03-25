class GalleryPhoto < ActiveRecord::Base
  acts_as_taggable
  acts_as_auditable :audit_unless_owner_attribute => :profile_id
  acts_as_rated :rater_class => "Profile", :rating_range => 1..5

  has_one :gallery_photo_attachment, :as => :owner, :dependent => :destroy
  belongs_to :group
  belongs_to :uploader, :class_name => 'Profile', :foreign_key => 'uploader_id'
  has_many :comments, :as => :owner, :order => "comments.created_at asc", :dependent => :destroy

  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  validates_presence_of [:group, :uploader]
  validates_length_of :caption, :within => 0..256, :allow_nil => true

  def editable_by?(profile)
    uploader == profile || group.editable_by?(profile)
  end

  def user_has_rated
    rated_by?(AuthenticatedSystem.current_profile)
  end

  def user_rating
    ratings.find(:first, :conditions => ['rater_id = ?', AuthenticatedSystem.current_profile.id]).rating
  end


  def find_next
    gallery_photos = self.group.gallery_photos
    index = gallery_photos.index(self)
    index -= 1
    index >= 0 ? gallery_photos[index] : nil
  end

  def find_previous
    gallery_photos = self.group.gallery_photos
    index = gallery_photos.index(self)
    index += 1
    gallery_photos[index]
  end
  
  def find_next_or_last
    find_next || find_previous
  end

end
