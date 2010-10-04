class AddColumnsToProfileAwards < ActiveRecord::Migration
  def self.up
    add_column :profile_awards, :is_default, :boolean, :default => false
    add_column :profile_awards, :visible, :boolean, :default => true
    add_column :profile_awards, :awarded_by, :string, :null => false
    add_column :profile_awards, :created_at, :datetime, :null => false
    add_column :profile_awards, :updated_at, :datetime, :null => false
    
    add_index :profile_awards, :is_default
    add_index :profile_awards, :visible
    add_index :profile_awards, :created_at
    add_index :profile_awards, [:profile_id, :award_id]
    add_index :profile_awards, :award_id
    
    
    add_column :awards, :created_at, :datetime, :null => false
    add_column :awards, :updated_at, :datetime, :null => false
    
    add_index :awards, :visible
    add_index :awards, :created_at
    
  end

  def self.down
    remove_column :profile_awards, :is_default
    remove_column :profile_awards, :visible
    remove_column :profile_awards, :awarded_by
    remove_column :profile_awards, :created_at
    remove_column :profile_awards, :updated_at
    
    remove_index :profile_awards, [:profile_id, :award_id]
    remove_index :profile_awards, :award_id
    
    remove_column :awards, :created_at
    remove_column :awards, :updated_at
    
    remove_index :awards, :visible
  end
end
