class AddIndices < ActiveRecord::Migration

  def self.up
  	add_index :votes, [:answer_id,:profile_id], :unique => true
  	add_index :abuses, [:abuseable_type,:abuseable_id], :unique => true
  	
  	add_index :attachments, [:parent_id, :thumbnail], :unique => true
  	add_index :attachments, [:type]
  	
  	add_index :question_profile_matches, :order
  	
  end
  
  def self.down
  	remove_index :votes, [:answer_id,:profile_id]
  	remove_index :abuses, [:abuseable_type,:abuseable_id]
  	
  	remove_index :attachments, [:type]
  	remove_index :attachments, [:parent_id, :thumbnail]
  	
  	remove_index :question_profile_matches, :order
  	
  end

end