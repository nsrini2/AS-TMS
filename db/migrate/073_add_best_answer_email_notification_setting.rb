class AddBestAnswerEmailNotificationSetting < ActiveRecord::Migration
  def self.up
    add_column :profiles, :best_answer_email_status, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :best_answer_email_status
  end
end
