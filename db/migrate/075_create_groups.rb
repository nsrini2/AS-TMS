class CreateGroups < ActiveRecord::Migration
  def self.up
      create_table :groups do |t|
        t.column :name, :string, :limit => 100, :null => false
        t.column :description, :string, :limit => 450, :null => false
        t.column :created_at, :datetime
        t.column :num_members, :integer
        t.column :primary_photo_id, :integer
        t.column :updated_at, :datetime
        t.column :tags, :string
    end
  end

  def self.down
     drop_table :groups
  end
end