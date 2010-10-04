class AddNotificationStatusesToProfile < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :keep_name_private
    remove_column :profiles, :keep_location_private
    
    add_column :profiles, :note_email_status, :integer, :default => 1
    add_column :profiles, :group_note_email_status, :integer, :default => 1
    add_column :profiles, :watched_question_answer_email_status, :integer, :default => 1
    add_column :profiles, :recommendation_on_question_email_status, :integer, :default => 1
    add_column :profiles, :matched_question_email_status, :integer, :default => 1
    add_column :profiles, :group_blog_post_email_status, :integer, :default => 1
    add_column :profiles, :group_post_email_status, :integer, :default => 1
    add_column :profiles, :group_referral_email_status, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :note_email_status
    remove_column :profiles, :group_note_email_status
    remove_column :profiles, :watched_question_answer_email_status
    remove_column :profiles, :recommendation_on_question_email_status
    remove_column :profiles, :matched_question_email_status
    remove_column :profiles, :group_blog_post_email_status
    remove_column :profiles, :group_post_email_status
    remove_column :profiles, :group_referral_email_status
  end
end
