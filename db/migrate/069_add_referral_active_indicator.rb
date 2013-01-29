class AddReferralActiveIndicator < ActiveRecord::Migration

  def self.up
    add_column :question_referrals, :active, :boolean, :null => false, :default => true
    add_index :question_referrals, :active
  end

  def self.down
    remove_column :question_referrals, :active
  end

end
