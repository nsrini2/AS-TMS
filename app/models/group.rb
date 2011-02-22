require_cubeless_engine_file :model, :group

class Group < ActiveRecord::Base  
  has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['active = 1'], :uniq  => true
end    