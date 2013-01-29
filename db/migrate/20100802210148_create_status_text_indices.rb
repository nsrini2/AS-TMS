class CreateStatusTextIndices < ActiveRecord::Migration
  def self.up
    create_table :status_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :status_id, :integer, :null => false
      t.column :body_text, :text
      t.column :author_text, :text
      t.timestamps
    end
    
    add_index :status_text_indices, :status_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_status on status_text_indices (body_text, author_text)"
    execute "CREATE FULLTEXT INDEX fulltext_status_body on status_text_indices (body_text)"
    execute "CREATE FULLTEXT INDEX fulltext_status_author on status_text_indices (author_text)"
  end

  def self.down
    drop_table :status_text_indices
  end
end
