class AddNameCctldSrwCodesToCountries < ActiveRecord::Migration
  def self.up
    remove_column :countries, :abbreviation
    remove_column :countries, :country
    add_column :countries, :name, :string
    add_column :countries, :cctld, :string
    add_column :countries, :srw_country_code, :string
    add_column :countries, :srw_region_code, :string
  end

  def self.down
    add_column :countries, :abbreviation, :string
    add_column :countries, :country, :string
    remove_column :countries, :name
    remove_column :countries, :cctld
    remove_column :countries, :srw_country_code
    remove_column :countries, :srw_region_code
  end
end
