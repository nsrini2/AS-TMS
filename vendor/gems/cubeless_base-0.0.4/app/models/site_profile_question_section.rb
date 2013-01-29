class SiteProfileQuestionSection < ActiveRecord::Base
  include Config::Callbacks

  has_many :site_profile_questions, :dependent => :nullify, :order => :position

end
