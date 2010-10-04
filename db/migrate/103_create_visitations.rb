class CreateVisitations < ActiveRecord::Migration
  def self.up
    create_table :visitations do |t|
      t.column :visitor_id,  :integer, :null => false
      t.column :blog_id, :integer, :null => false
      t.column :updated_at, :datetime
    end
    add_index :visitations, [:blog_id, :visitor_id], :unique => true
  end

  def self.down
    drop_table :visitations
    remove_index :visitations, [:blog_id, :visitor_id]
  end
end