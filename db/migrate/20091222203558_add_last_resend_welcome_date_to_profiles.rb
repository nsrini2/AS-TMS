class AddLastResendWelcomeDateToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :last_sent_welcome_at, :datetime, :null => true
  end

  def self.down
   remove_column :profiles, :last_sent_welcome_at
  end
end
