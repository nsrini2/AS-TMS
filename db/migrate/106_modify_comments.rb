class ModifyComments < ActiveRecord::Migration

  def self.up
    rename_column :comments, :author_id, :profile_id
  end

  def self.down
    rename_column :comments, :profile_id, :author_id
  end

end