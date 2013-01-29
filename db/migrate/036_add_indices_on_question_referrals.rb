class AddIndicesOnQuestionReferrals < ActiveRecord::Migration
  def self.up
    add_index :question_referrals, :question_id
    add_index :question_referrals, :referer_id
    add_index :question_referrals, :profile_id
    
  end
  
  def self.down
    remove_index :question_referrals, :question_id
    remove_index :question_referrals, :referer_id
    remove_index :question_referrals, :profile_id
  end
end
