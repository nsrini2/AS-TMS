require 'digest/sha1'
require File.join(File.dirname(__FILE__), '../concerns/user_reports')
require 'user_password_validator'

class User < ActiveRecord::Base
  extend UserReports::ClassMethods
  
  acts_as_modified
  xss_terminate :except => [:crypted_password_history]

  has_one :profile, :dependent => :destroy

  attr_accessor :password, :password_confirmation, :current_password
  attr_protected :login, :sso_id, :crypted_password, :temp_crypted_password, :salt, :access_key, :unsuccessful_login_attempts, :tfce_req_nonce, :tfce_res_nonce
  
  serialize :crypted_password_history, Array

  validates_presence_of :login, :if => :uses_login_pass?
  validates_length_of       :login,    :within => 2..45, :allow_blank => true, :if => :uses_login_pass?
  #!O #!H change validation so only individual spaces are allowed. reconsider underscore, dash.
  validates_format_of :login, :with => /^[\w\W\s\-]+$/i,
                                    :message => "is invalid. Please try another.",
                                    :allow_blank => true,
                                    :if => :uses_login_pass?
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_blank => true, :if => :uses_login_pass?  
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 3..100, :allow_blank => true
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
                      :allow_blank => true,
                      :message => 'must be a valid email address, e.g. a@b.com'

  # Authenticates a user by their login id and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.correct_password?(password) ? u : nil
  end

  def self.active_users_emails
    ActiveRecord::Base.connection.select_all("select u.email from users u, profiles p where u.id = p.user_id and p.status = 1").collect{|x| x["email"]}.compact.uniq
  end

  def correct_password?(password)
    crypted_password && crypted_password==encrypt(password)
  end
  
  def generate_temp_crypted_password(expires_at=24.hours.from_now)
    self.temp_crypted_password = encrypt(rand.to_s)
    self.temp_crypted_password_expires_at = expires_at
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def uses_login_pass?
    self.sso_id.blank? && self.srw_agent_id.blank?
  end

  def can_change_email?
    uses_login_pass?
  end

  def locked?
    locked_until && locked_until >= Time.now
  end

  def reset_password_requested?
    !temp_crypted_password.blank?
  end

  def crypted_password_history
    super || self.crypted_password_history=[]
  end

  # after_save :check_for_temp_user_migration
  # def check_for_temp_user_migration    
  #   # TODO: This is very inefficient, checking everytime a user is saved
  #   if self.profile && self.profile.status == 1      
  #     if temp_user = TempUser.find_by_user_id(self.id)
  #       temp_user.reviews.not_verified.each { |r| r.update_attribute(:user_id, self.id) }
  #     end
  #   end
  # end
  
  def temp_user_migration
    if temp_user = TempUser.find_by_user_id(self.id)
      temp_user.reviews.not_verified.each { |r| r.update_attribute(:user_id, self.id) }
    end
  end

  protected

  def password_requires_validation?
    uses_login_pass? && new_record?
  end

  def before_save
    if new_record?
      self.access_key = Digest::SHA1.hexdigest("access_key--#{Time.now.to_s}--#{login}--")
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")
    end
    if self.password
      if @@password_no_reuse_times>0
        pp = self.crypted_password_history
        pp << self.crypted_password if self.crypted_password && !pp.member?(self.crypted_password)
        while (pp.size>=@@password_no_reuse_times) do pp.delete_at(0) end
      end
      self.crypted_password = encrypt(password)
      self.password_changed_at = Time.now
    end
  end

  @@password_validator = UserPasswordValidator.new
  @@password_no_reuse_times = Config['user.pwd.no_reuse.times'].to_i
  def validate
    if uses_login_pass? && password && !Config[:registration_queue]
      # form validation helpers, only when passed
      return self.errors.add_to_base("Current password is invalid") unless correct_password?(current_password) if current_password
      return self.errors.add_to_base("Passwords do not match") unless password==password_confirmation if password_confirmation
      @@password_validator.validate(password).each { |error| self.errors.add_to_base(error) }
      new_crypted_password = encrypt(self.password)
      if @@password_no_reuse_times>0 && (self.crypted_password==new_crypted_password || self.crypted_password_history.member?(new_crypted_password))
        return self.errors.add_to_base("You cannot reuse any of your last #{@@password_no_reuse_times} passwords")
      end
    end
  end
  
  private

  # Encrypts the password with the user salt
  def encrypt(password)
    Digest::SHA1.hexdigest("--#{self.salt}--#{password}--")
  end
  
end
