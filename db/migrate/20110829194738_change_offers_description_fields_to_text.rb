class ChangeOffersDescriptionFieldsToText < ActiveRecord::Migration
  def self.up
    change_column :offers, :description, :text
    change_column :offers, :short_description, :text
  end

  def self.down
  end
end
