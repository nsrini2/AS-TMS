class CreateVoteUniqueConstraint < ActiveRecord::Migration

  def self.up
    remove_index :votes, [:owner_type,:owner_id, :profile_id]
    add_index :votes, [:owner_type,:owner_id, :profile_id], :unique => true
  end

  def self.down
  end

end
