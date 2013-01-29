class AddPlanCountry < ActiveRecord::Migration

  def self.up
    add_column :plans, :loc_country, :string
  end

  def self.down
    remove_column :plans, :loc_country
  end

end