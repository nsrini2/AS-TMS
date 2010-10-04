class AddWidgetConfig < ActiveRecord::Migration
  def self.up
    add_column :profiles, :widget_config, :string
  end

  def self.down
    remove_column :profiles, :widget_config
  end
end