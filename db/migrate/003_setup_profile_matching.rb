class SetupProfileMatching < ActiveRecord::Migration

  def self.up
    create_table :question_profile_matches do |t|
    	t.column :question_id, :integer, :null => false
    	t.column :profile_id, :integer, :null => false
    	t.column :rank, :float, :null => false
      t.column :order, :integer, :null => false
    end
    add_index :question_profile_matches, :question_id
    add_index :question_profile_matches, :profile_id
    add_index :question_profile_matches, :rank
    add_index :question_profile_matches, [:question_id, :profile_id], :unique => true
        
    create_table :question_profile_exclude_matches do |t|
      t.column :question_id, :integer, :null => false
      t.column :profile_id, :integer, :null => false
    end
    add_index :question_profile_exclude_matches, [:question_id, :profile_id], :unique => true, :name => 'qpim_unique_pair'
    
  end

  def self.down
    drop_table :question_profile_matches
    drop_table :question_profile_exclude_matches
  end
  
end
