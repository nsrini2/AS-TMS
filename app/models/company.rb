class Company < ActiveRecord::Base
  has_one :blog, :as => :owner, :dependent => :destroy
  has_many :profiles
  has_many :members, :class_name => "Profile", :conditions => ["status = ?", 1]
  has_one :company_photo, :as => :owner, :dependent => :destroy
  belongs_to :primary_photo, :class_name => 'CompanyPhoto', :foreign_key => :primary_photo_id
  has_many :groups, :conditions => 'groups.company_id = #{self.id}'
  
  default_scope :conditions => ["#{table_name}.active = 1"]
  
  validates_presence_of :name, :description
  
  def to_s
    name.to_s
  end
  
  def primary_photo_path(which=:thumb)
    primary_photo.public_filename(which) if !primary_photo.nil?
  end
  
  def owner
    Profile.find(self.owner_id)
  end

  
  def answers
    a = []
    self.questions.each do |q|
      a << q.answers
    end 
    a.flatten
  end
  
  def questions
    # do to the unscoped nature of questions -- this is not a has_many
    Question.company_questions(self.id)
  end
    
  def after_create
    self.create_blog
  end  
  
  class << self
    def view_selector
      Company.all.map { |c| [c.name, c.id] }
    end  
  end  
end
