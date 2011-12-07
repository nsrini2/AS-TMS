class Retrieval < ActiveForm
  attr_accessor :email
  attr_accessor :item
  attr_accessor :login
  attr_accessor :pending

  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
                      :if => :is_for_login?,
                      :message => 'must be a valid email address, e.g. a@b.com'

  validates_presence_of :email , :if => :is_for_login?
  validates_presence_of :login , :if => :is_for_password?
 
  def is_for_login?
    self.item == 'login'
  end

  def is_for_password?
    self.item == 'password'
  end
  
  def is_pending?
    user = User.find_by_login(self.login) if is_for_password?
    self.pending = user.profile.status  
    self.pending == -3
  end
   
  def validate
    if is_for_login?
      errors.add_to_base "We do not have a user with the email address specified" if User.find(:first, :conditions => ["email = ?", self.email]).nil?
    end
    if is_for_password?
      errors.add_to_base "We do not have a user with the login specified" if User.find(:first, :conditions => ["login = ?", self.login]).nil?
    end
    if is_for_password? && errors.empty? 
      errors.add_to_base 'Your profile is still pending approval.' if is_pending?  
    end                 
  end
end