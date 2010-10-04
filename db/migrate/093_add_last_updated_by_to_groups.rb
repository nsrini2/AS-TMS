class AddLastUpdatedByToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :last_updated_by, :integer
    execute "Update groups set last_updated_by = (select id from profiles limit 1)"
    change_column :groups, :last_updated_by, :integer, :null => false
  end

  def self.down
    remove_column :groups, :last_updated_by
  end
end
