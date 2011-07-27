class Company < ActiveRecord::Base
  has_many :profiles
  has_many :members, :class_name => "Profile", :conditions => ["status = ?", 1]
  has_one :company_photo, :as => :owner, :dependent => :destroy
  belongs_to :primary_photo, :class_name => 'CompanyPhoto', :foreign_key => :primary_photo_id
  
  has_many :groups, :conditions => 'groups.company_id = #{self.id}'
  
  default_scope :conditions => ["active = 1"]
  
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
      puts q.inspect
      a << q.answers
    end 
    a.flatten
  end
  
  def questions
    # do to the unscoped nature of questions -- this is not a has_many
    Question.company_questions(self.id)
  end
    
# ********************************
# at some point this will be a has many association at top, but that is not yet defined
  # def groups
  #   # Group.find(:all, :limit => 3 )
  #   []
  # end
# ********************************
end
