class AddNoteAndGroupsAllowedToSponsorAccount < ActiveRecord::Migration
  def self.up
    add_column :sponsor_accounts, :note, :text
    add_column :sponsor_accounts, :groups_allowed, :integer
  end

  def self.down
    remove_column :sponsor_accounts, :note
    remove_column :sponsor_accounts, :groups_allowed
  end
end
