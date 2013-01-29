class AddActiveStatus < ActiveRecord::Migration
  
  def self.up
    add_column :users, :external_id, :string
    add_column :users, :active, :boolean, :default => true, :null => false
    execute('update users u set external_id=(select external_id from profiles p where p.user_id=u.id)')
    add_index :users, :external_id
    add_index :users, :active
    remove_column :profiles, :external_id
    
    add_column :profiles, :alt_first_name, :string
    add_column :profiles, :alt_last_name, :string

    add_index :profiles, :first_name
    add_index :profiles, :last_name
    add_index :profiles, :alt_first_name
    add_index :profiles, :alt_last_name
    
  end

  def self.down
    add_column :profiles, :external_id, :string
    execute('update profiles p set external_id=(select external_id from users u where u.id=p.user_id)')    
    add_index :profiles, :external_id
    remove_column :users, :external_id
    remove_column :users, :active    

    remove_index :profiles, :first_name
    remove_index :profiles, :last_name
    remove_column :profiles, :alt_first_name
    remove_column :profiles, :alt_last_name    
    
  end
  
end