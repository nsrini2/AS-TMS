class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column "answer_id", :integer
      t.column "profile_id",  :integer
    end
  end

  def self.down
    drop_table :votes
  end
end
