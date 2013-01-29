class AddShortDescriptionToOffer < ActiveRecord::Migration
  def self.up
    add_column :offers, :short_description, :string
  end

  def self.down
  end
end
