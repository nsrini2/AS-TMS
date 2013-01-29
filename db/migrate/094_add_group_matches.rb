class AddGroupMatches < ActiveRecord::Migration

  def self.up
    create_table :group_question_matches do |t|
      t.column :created_at, :datetime, :null => false
      t.column :group_id, :integer, :null => false
      t.column :question_id, :integer, :null => false
      t.column :removed, :boolean, :null => false, :default => false
      t.column :rank, :float, :null => false
    end
    add_index :group_question_matches, [:group_id,:question_id], :unique => true
    add_index :group_question_matches, [:removed, :group_id]
    add_index :group_question_matches, :created_at

  end

  def self.down
    drop_table :group_question_matches
  end

end
