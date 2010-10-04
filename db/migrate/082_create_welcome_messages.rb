class CreateWelcomeMessages < ActiveRecord::Migration
  def self.up
    remove_column :notes, :is_default
    create_table :welcome_messages do |t|
      t.column :profile_id, :integer
      t.column :text, :string, :limit => 100
    end
  end

  def self.down
    drop_table :welcome_messages
    add_column :notes, :is_default, :boolean
  end
end
