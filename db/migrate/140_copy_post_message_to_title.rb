class CopyPostMessageToTitle < ActiveRecord::Migration

  def self.up
    execute "update posts set title=left(message,50) where title is null"
    change_column :posts, :title, :string, :limit => 300, :null => false
  end

  def self.down
    change_column :posts, :title, :string, :limit => 300, :null => true
  end

end