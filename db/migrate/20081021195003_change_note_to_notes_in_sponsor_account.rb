class ChangeNoteToNotesInSponsorAccount < ActiveRecord::Migration
  def self.up
    rename_column :sponsor_accounts, :note, :notes
  end

  def self.down
    rename_column :sponsor_accounts, :notes, :note
  end
end
