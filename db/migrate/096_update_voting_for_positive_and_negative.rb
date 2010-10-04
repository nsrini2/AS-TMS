class UpdateVotingForPositiveAndNegative < ActiveRecord::Migration
  def self.up
    add_column :votes, :vote_value, :boolean
    execute "update votes set vote_value = true"
    change_column :votes, :vote_value, :boolean, :null => false
    add_index :votes, :vote_value
  end

  def self.down
    remove_column :votes, :vote_value
  end
end
