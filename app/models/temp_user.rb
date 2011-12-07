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
  
  def upgrade
    user = User.new(:email => self.email)
    user.login = self.email
    
    profile = Profile.new
    profile.user = user
    profile.first_name = self.first_name
    profile.last_name = self.last_name
    
    here user.inspect
    here profile.inspect

    profile.status = 3 # Lazy registration
    profile.visible = 0
    profile.add_roles Role::DirectMember
    profile.screen_name = self.name
    profile.pcc = self.pcc

    # # Grab regitrations details to be validated seperately
    # # Also associate it with the profile
    # @registration = Registration.new(params[:registration])
    # @profile.registration = @registration
    
    here user.valid?
    here profile.valid?
    
    here user.errors.full_messages
    here profile.errors.full_messages
    
    saved = user.save && profile.save
    
    if saved
      self.update_attribute(:user_id, user.id)
      user.profile = profile
      here user.inspect
      here profile.inspect
      
      Notifier.deliver_welcome(user)
    end
    
    saved
  end

end
