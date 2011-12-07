class AddTravelExtraFields < ActiveRecord::Migration
  def self.up
    add_column :offers, :price, :int
    add_column :offers, :inclusions, :string
    add_column :offers, :exclusions, :string
    add_column :offers, :notes, :string
    add_column :offers, :redemption_policies, :string
    add_column :offers, :agency_commission_discount, :string
    add_column :offers, :booking_info, :string
  end

  def self.down
    remove_column :offers, :price
    remove_column :offers, :inclusions
    remove_column :offers, :exclusions
    remove_column :offers, :notes
    remove_column :offers, :redemption_policies
    remove_column :offers, :agency_commission_discount
    remove_column :offers, :booking_info
  end
end
