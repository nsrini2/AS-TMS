class AddCityToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :city, :string
  end

  def self.down
  end
end
