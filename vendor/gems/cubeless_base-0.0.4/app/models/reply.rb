class Reply < ActiveRecord::Base

  acts_as_auditable :audit_unless_owner_attribute => :profile_id
  belongs_to :answer
  belongs_to :profile
  has_one :abuse, :as => :abuseable, :conditions => 'remover_id is null'

  def self.find(*args)
    with_scope(:find => {:include => :profile}) do
      super(*args)
    end
  end

  def validate
    if text.to_s.length == 0
      errors.add_to_base("Reply cannot be blank")
    elsif text.to_s.length > 4000
      errors.add_to_base("Reply is too long (maximum is 256 characters)")
    end
  end
end