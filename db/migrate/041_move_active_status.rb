class MoveActiveStatus < ActiveRecord::Migration

  def self.up
    add_column :profiles, :status, :integer, :null => false, :default => 1
    execute 'update profiles p set status=(select active from users u where u.id=p.user_id)'
    add_index :profiles, :status
    remove_column :users, :active
  end

  def self.down
    add_column :users, :active, :integer, :null => false, :default => 1
    execute 'update users u set active=(select status from profiles p where u.id=p.user_id)'
    add_index :users, :active
    remove_column :profiles, :status
  end

end
