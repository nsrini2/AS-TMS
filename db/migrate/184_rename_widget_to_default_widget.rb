class RenameWidgetToDefaultWidget < ActiveRecord::Migration
  
  def self.up
    rename_table :widgets, :default_widgets
  end
  
  def self.down
    rename_table :default_widgets, :widgets
  end
  
end