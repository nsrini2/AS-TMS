class AddExtraFieldsToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :price, :string
    add_column :offers, :operating_hours, :string
    add_column :offers, :inclusions, :string
    add_column :offers, :exclusions, :string
    add_column :offers, :notes, :string
    add_column :offers, :redemption_policies, :string
    add_column :offers, :commission_discount, :string
  end

  def self.down
  end
end
