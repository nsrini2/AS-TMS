class AddAttachmentsPolyIndex < ActiveRecord::Migration
  def self.up
    add_index :attachments, [:owner_type,:owner_id]
  end

  def self.down
    remove_index :attachments, :column => [:owner_type,:owner_id]
  end
end
