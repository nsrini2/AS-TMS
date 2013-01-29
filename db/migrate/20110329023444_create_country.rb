class CreateCountry < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.timestamps
      
      t.string :abbreviation
      t.string :country
    end
  end

  def self.down
  end
end
