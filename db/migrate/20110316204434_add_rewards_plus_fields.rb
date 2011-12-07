class AddRewardsPlusFields < ActiveRecord::Migration
  def self.up
    add_column :offers, :campaign_name, :string
    add_column :offers, :point_value, :int
    add_column :offers, :marketing_title, :string
  end

  def self.down
    remove_column :offers, :campaign_name
    remove_column :offers, :point_value
    remove_column :offers, :marketing_title
  end
end
