require_cubeless_engine_file :model, :group

class Group < ActiveRecord::Base
  include Notifications::Group  
  belongs_to :company
  
  has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['active = 1'], :uniq  => true
    
  has_many :active_questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['active = 1 and questions.open_until > ?', Date.today], :uniq  => true
    
end    