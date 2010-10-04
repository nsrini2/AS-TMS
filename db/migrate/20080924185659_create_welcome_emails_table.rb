class CreateWelcomeEmailsTable < ActiveRecord::Migration
  def self.up
    create_table :welcome_emails do |t|
        t.column :content, :text
    end
  end

  def self.down
    drop_table :welcome_emails
  end
end
