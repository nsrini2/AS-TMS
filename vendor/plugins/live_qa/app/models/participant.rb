class Participant < ActiveRecord::Base
  @@STATES = ["rsvp", "canceled", "attended", "contributed" ]
  
  belongs_to :profile
  belongs_to :chat
  has_many :posts
  validates_uniqueness_of   :profile_id, :scope => :chat_id
  validates_inclusion_of    :status, :in => @@STATES

  named_scope :rsvp, :conditions => 'status = "rsvp" '
  named_scope :attendee, :conditions => 'status = "attended" OR status = "contributed" '
  
  def active?
    true
  end
  
  def contributor?
    true
  end
  
  class << self
    
    def set_status(chat, profile_id, status)
      if @@STATES.include?(status)
        participant = chat.participants.find_or_initialize_by_profile_id(profile_id)
        participant.status = participant.status || status
        current_status = participant.status
        case current_status
        when "contributed"
          # once a contributer always a contributer  
        when "attended"
          # can only be upgraded to contributed
          participant.status = status if status == "contributed"
        when "rsvp", "canceled"
          # if my status is rsvp or canceled I can be changed at will
          participant.status = status
        end
        participant.save
      end
    end
    
    
  end  
end
