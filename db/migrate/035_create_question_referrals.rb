class CreateQuestionReferrals < ActiveRecord::Migration
  def self.up
    create_table :question_referrals do |t|
      t.column :question_id, :integer
      t.column :profile_id, :integer
      t.column :referer_id, :integer
    end
  end

  def self.down
    drop_table :question_referrals
  end
end
