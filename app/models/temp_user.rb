class TempUser < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :reviews

  def first_name
    split_name.first
  end
  
  def last_name
    split_name[1..-1].join(" ")
  end
  
  def split_name
    @split_name ||= name.to_s.split(" ")
  end

  def custom_valid?
    if self.name.blank? || self.email.blank? || self.pcc.blank?
      false
    else
      true
    end
  end

  def auto_approve?
    custom_valid? && ConfirmedEmailPcc.match(self.email, self.pcc)
  end
  
  def notice
    if auto_approve?
      "Thank for you registering.<br/><br/>PLEASE ALLOW 2-3 BUSINESS DAYS FOR PROCESSING as we manually verify your registration.  Your patience with our detailed review process is certainly appreciated as member privacy and security continues to be our top priority."
    elsif custom_valid?
      "We could not automatically verify your account using only the PCC and email address provided.<br/><br/>Please fill out the additional information below."
    end     
  end
  
  def upgrade
    user = User.new(:email => self.email)
    user.login = self.email
    
    profile = Profile.new
    profile.user = user
    profile.first_name = self.first_name
    profile.last_name = self.last_name

    profile.status = 3 # Lazy registration
    profile.visible = 0
    profile.add_roles Role::DirectMember
    profile.screen_name = self.name
    profile.pcc = self.pcc

    # # Grab regitrations details to be validated seperately
    # # Also associate it with the profile
    # @registration = Registration.new(params[:registration])
    # @profile.registration = @registration
    
    saved = user.save && profile.save
    
    if saved
      self.update_attribute(:user_id, user.id)
      user.profile = profile
      
      Notifier.deliver_welcome(user)
    end
    
    saved
  end

end
