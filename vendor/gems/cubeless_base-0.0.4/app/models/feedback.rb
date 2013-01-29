class Feedback < ActiveForm

  attr_accessor :name, :email, :subject, :body

  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :body

  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
                      :message => 'must be a valid email address, e.g. a@b.com'
                      
end