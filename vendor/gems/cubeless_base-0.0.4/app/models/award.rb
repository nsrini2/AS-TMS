class Award < ActiveRecord::Base

  has_one :award_image, :as => :owner, :dependent => :destroy
  has_many :profile_awards
  has_many :profiles, :through => :profile_awards
  
  validates_presence_of :award_image, :on => :create

  named_scope :visible, :conditions => { :visible => true }
  named_scope :hidden, :conditions => { :visible => false }
  named_scope :visibility_matching, lambda {|x| { :conditions => { :visible => x.visible } }}
  named_scope :visibility_not_matching, lambda {|x| { :conditions => { :visible => !x.visible } }}

  def self.find(*args)
    options = ModelUtil.get_options!(args)
    if !options.include? :order
      options[:order] = 'created_at DESC'
    end
    super
  end

  def toggle_visibility!
    self.toggle!(:visible)
  end

  def assign(profile)
    self.profiles << profile
  end

  def recipients
    ProfileAward.find_all_by_award_id(self.id).collect(&:profile)
  end

  def copy!
    Award.transaction do
      award_copy = self.clone
      award_copy.created_at = Time.now
      award_copy.title = award_copy.title.insert(0, 'COPY: ') if award_copy.title
      award_copy.award_image = self.award_image.copy
      award_copy.save!
    end
  end

  def editable_by?(profile)
    profile.has_role?(Role::AwardsAdmin)
  end
end