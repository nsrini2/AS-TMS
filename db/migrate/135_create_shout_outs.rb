class CreateShoutOuts < ActiveRecord::Migration
  def self.up
    create_table :shout_outs do |t|
      t.datetime :created_at, :null => false
      t.integer :group_id, :null => false
      t.integer :profile_id, :null => false
      t.text :message, :null => false
    end
    add_index :shout_outs, :created_at
    add_index :shout_outs, :group_id
    add_index :shout_outs, :profile_id
  end

  def self.down
    drop_table :shout_outs
  end
end
