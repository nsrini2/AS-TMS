class AddQuestionDailySummaryEmail < ActiveRecord::Migration
  def self.up
    add_column :questions, :daily_summary_email, :boolean, :default => 0
  end

  def self.down
    remove_column :questions, :daily_summary_email
  end
end
