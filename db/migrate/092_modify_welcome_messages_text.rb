class ModifyWelcomeMessagesText < ActiveRecord::Migration
  def self.up
    change_column :welcome_messages, :text, :text
  end

  def self.down
  end
end
