class AddReplyAndSubjectToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :replied_to, :integer
    add_column :messages, :subject, :string, :null => false
  end

  def self.down
    remove_column :messages, :replied_to
    remove_column :messages, :subject
  end
end
