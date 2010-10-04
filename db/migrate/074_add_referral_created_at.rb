class AddReferralCreatedAt < ActiveRecord::Migration
  def self.up
    add_column :question_referrals, :created_at, :datetime
    execute "update question_referrals set created_at = now()"
  end

  def self.down
    remove_column :question_referrals, :created_at
  end
end
