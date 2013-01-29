class AddUserImportBypassFlag < ActiveRecord::Migration
  
  def self.up
    rename_column :users, :external_id, :sso_id
    add_column :users, :sync_exclude, :boolean, :null => false, :default => false
  end

  def self.down
    drop_column :users, :sync_exclude
    rename_column :users, :sso_id, :external_id
  end

end
