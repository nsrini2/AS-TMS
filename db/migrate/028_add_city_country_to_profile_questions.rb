class AddCityCountryToProfileQuestions < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :hometown, :hometown_city
    add_column :profiles, :hometown_country, :string
    
    rename_column :profiles, :live_now, :live_now_city
    add_column :profiles, :live_now_country, :string
  end
  
  def self.down
    rename_column :profiles, :hometown_city, :hometown
    remove_column :profiles, :hometown_country
    
    rename_column :profiles, :live_now_city, :live_now
    remove_column :profiles, :live_now_country
  end
end