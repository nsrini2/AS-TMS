class CorrectVoteIndices < ActiveRecord::Migration
  def self.up
    remove_index :votes, :name => 'index_votes_on_answer_id_and_profile_id' # column renamed
    remove_index :votes, :owner_type
    add_index :votes, [:owner_type,:owner_id, :profile_id]
  end

  def self.down
    raise 'cant go back'
  end
end
