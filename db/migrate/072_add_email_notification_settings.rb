class AddEmailNotificationSettings < ActiveRecord::Migration
  def self.up
    add_column :profiles, :summary_email_status, :integer, :default => 1
    add_column :profiles, :referral_email_status, :integer, :default => 1
    add_column :profiles, :closing_email_status, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :summary_email_status
    remove_column :profiles, :referral_email_status
    remove_column :profiles, :closing_email_status
  end
end
