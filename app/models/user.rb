require_cubeless_engine_file :model, :user
require_de_engine_file :model, :user

class User
  include Notifications::User
  
  def take_survey!
    self.take_survey = true
    self.save!
  end
  
  def survey_taken!
    self.take_survey = false
    self.save!
  end
end