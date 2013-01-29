class AddReplyNotificationPreference < ActiveRecord::Migration
  def self.up
    add_column :profiles, :new_reply_on_answer_notification, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :new_reply_on_answer_notification
  end
end
