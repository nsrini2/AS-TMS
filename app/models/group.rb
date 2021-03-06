require_cubeless_engine_file :model, :group

class Group < ActiveRecord::Base
  include Notifications::Group
  include Indexed::Add
    
  belongs_to :company
  
  has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['question_referrals.active = 1'], :uniq  => true
    
  has_many :active_questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['question_referrals.active = 1 and questions.open_until > ?', Date.today], :uniq  => true
    
  def search_content
    tags
  end
  
  @@de_values = { 0 => false, 1 => true }
  def de_allowed?
     @@de_values[de_flag]
  end
    
end    
