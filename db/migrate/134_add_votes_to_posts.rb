class AddVotesToPosts < ActiveRecord::Migration
  def self.up
    rename_column :votes, :answer_id, :owner_id
    add_column :votes, :owner_type, :string, :null => false

    execute "update votes set owner_type='Answer'"

    # add_column :posts, :num_positive_votes, :integer, :null => false, :default => 0
    # add_column :posts, :num_negative_votes, :integer, :null => false, :default => 0
    # add_column :posts, :net_helpful, :integer, :null => false, :default => 0

    add_index :votes, :owner_type
    # add_index :posts, :net_helpful
  end

  def self.down
    rename_column :votes, :owner_id, :answer_id
    remove_column :votes, :owner_type

    # remove_column :posts, :num_positive_votes
    # remove_column :posts, :num_negative_votes
    # remove_column :posts, :net_helpful
  end
end