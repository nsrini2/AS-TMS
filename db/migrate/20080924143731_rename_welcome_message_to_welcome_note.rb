class RenameWelcomeMessageToWelcomeNote < ActiveRecord::Migration
  def self.up
    rename_table :welcome_messages, :welcome_notes
  end

  def self.down
    rename_table :welcome_notes, :welcome_messages
  end
end
