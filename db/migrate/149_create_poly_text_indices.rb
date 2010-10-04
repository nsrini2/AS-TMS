class CreatePolyTextIndices < ActiveRecord::Migration

  def self.up

    create_table :poly_text_indices, :options => "ENGINE=MyISAM" do |t|
      t.string :owner_type, :null => false
      t.integer :owner_id, :null => false
      t.string :domain
      t.text :text
    end
    add_index :poly_text_indices, [:owner_type,:owner_id]
    add_index :poly_text_indices, [:owner_type,:domain,:owner_id]
    execute "CREATE FULLTEXT INDEX fulltext_text on poly_text_indices (text)"

  end

  def self.down
    drop_table :poly_text_indices
  end

end
