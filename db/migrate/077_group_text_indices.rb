class GroupTextIndices < ActiveRecord::Migration
  def self.up
    create_table :group_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.column :group_id, :integer, :null => false
      t.column :name_text, :text
      t.column :description_text, :text
      t.column :tags_text, :text
    end
    add_index :group_text_indices, :group_id, :unique => true
    execute "CREATE FULLTEXT INDEX fulltext_group on group_text_indices (name_text, description_text, tags_text)"
  end

  def self.down
    drop_table :group_text_indices
  end
end