class AddPolymorphismToQuestionReferrals < ActiveRecord::Migration

  def self.up
    rename_column :question_referrals, :profile_id, :owner_id
    add_column :question_referrals, :owner_type, :string, :null => false

    execute 'update question_referrals set owner_type = "Profile"'
  end

  def self.down
    rename_column :question_referrals, :owner_id, :profile_id
    remove_column :question_referrals, :owner_type
  end

end