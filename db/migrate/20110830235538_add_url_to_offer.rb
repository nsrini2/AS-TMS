class AddUrlToOffer < ActiveRecord::Migration
  def self.up
    add_column :offers, :url, :text
  end

  def self.down
    add_column :offers, :url
  end
end
