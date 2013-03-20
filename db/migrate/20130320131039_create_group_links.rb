class CreateGroupLinks < ActiveRecord::Migration
  def self.up
    create_table :group_links do |t|
      t.string :url
      t.string :text
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :group_links
  end
end
