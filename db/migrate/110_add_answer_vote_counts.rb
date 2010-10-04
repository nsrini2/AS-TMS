class AddAnswerVoteCounts < ActiveRecord::Migration
  def self.up
    add_column :answers, :num_positive_votes, :integer, :null => false, :default => 0
    add_column :answers, :num_negative_votes, :integer, :null => false, :default => 0
    add_column :answers, :net_helpful, :integer, :null => false, :default => 0

    # set answer vote counts for existing votes
    execute "update answers a join (select answer_id as vote_answer_id, sum(if(vote_value,1,0)) as num_positive_votes, sum(if(vote_value,0,1)) as num_negative_votes, sum(if(vote_value,1,-1)) as net_helpful from votes group by answer_id) as vote_counts on vote_answer_id=a.id set a.num_positive_votes = vote_counts.num_positive_votes, a.num_negative_votes = vote_counts.num_negative_votes, a.net_helpful = vote_counts.net_helpful"

    add_index :answers, :net_helpful
  end

  def self.down
    remove_column :answers, :num_positive_votes
    remove_column :answers, :num_negative_votes
    remove_column :answers, :net_helpful
  end
end
