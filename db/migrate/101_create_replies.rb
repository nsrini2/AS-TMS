class CreateReplies < ActiveRecord::Migration
  def self.up
    create_table :replies do |t|
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :answer_id,    :integer, :null => false
      t.column :profile_id, :integer, :null => false
      t.column :text,       :text, :null => false
    end
  end

  def self.down
    drop_table :replies
  end
end
