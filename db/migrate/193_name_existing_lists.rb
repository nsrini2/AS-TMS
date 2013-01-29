class NameExistingLists < ActiveRecord::Migration
  def self.up
    execute "update poi_lists set name = 'My first list'"
  end

  def self.down
    execute "update poi_lists set name = null"
  end
end
