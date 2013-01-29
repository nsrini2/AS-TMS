
class TextIndexes < ActiveRecord::Migration
  
  def self.up

    create_table :profile_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :profile_id, :integer, :null => false
      t.column :profile_text, :text
      t.column :answers_text, :text
    end
    add_index :profile_text_indices, :profile_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_profile on profile_text_indices (profile_text,answers_text)"
    
    create_table :question_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :question_id, :integer, :null => false
      t.column :question_text, :text 
    end
    add_index :question_text_indices, :question_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_question on question_text_indices (question_text)"   
    
  end
  
  def self.down
    drop_table :profile_text_indices
    drop_table :question_text_indices
  end  
  
end