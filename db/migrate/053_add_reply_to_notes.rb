class AddReplyToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :replied_to, :integer
  end

  def self.down
    remove_column :notes, :replied_to
  end
end
