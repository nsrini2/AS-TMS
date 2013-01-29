class UpdateWidgetConfigColumn < ActiveRecord::Migration
  def self.up
    change_column :profiles, :widget_config, :text
  end

  def self.down
  end
end
