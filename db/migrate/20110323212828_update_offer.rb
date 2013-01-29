class UpdateOffer < ActiveRecord::Migration
  def self.up
    
    rename_column :offers, :start_date, :sell_effective_date
    rename_column :offers, :end_date, :sell_discontinue_date

    remove_column :offers, :hotel_chain_code
    remove_column :offers, :hotel_property_id
    remove_column :offers, :destination_airport_code
    remove_column :offers, :state_id
    remove_column :offers, :destination_country
    remove_column :offers, :property_name
    remove_column :offers, :address
    remove_column :offers, :address2
    remove_column :offers, :address3
    remove_column :offers, :lat
    remove_column :offers, :long
    remove_column :offers, :city
    remove_column :offers, :zip
    remove_column :offers, :ad_text
    remove_column :offers, :campaign_name
    remove_column :offers, :point_value
    remove_column :offers, :marketing_title
    remove_column :offers, :price
    remove_column :offers, :inclusions
    remove_column :offers, :exclusions
    remove_column :offers, :notes
    remove_column :offers, :redemption_policies
    remove_column :offers, :agency_commission_discount
    remove_column :offers, :booking_info
    
  end

  def self.down
  end
end
