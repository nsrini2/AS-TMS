class AddIndexForReferral < ActiveRecord::Migration
  def self.up
    #074
    #change_column :question_referrals, :created_at, :datetime, :null => false # (tries to set default null)
    execute 'ALTER TABLE question_referrals MODIFY COLUMN created_at DATETIME NOT NULL'

    add_index :question_referrals, :created_at
  end

  def self.down
    remove_index :question_referrals, :created_at
  end
end