class AddSubjectToWelcomeEmail < ActiveRecord::Migration
  def self.up
    add_column :welcome_emails, :subject, :string
  end

  def self.down
    remove_column :welcome_emails, :subject
  end
end
