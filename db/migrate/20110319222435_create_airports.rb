class CreateAirports < ActiveRecord::Migration
  def self.up
    create_table :airports do |t|
      t.timestamps
      t.string :airport_code
      t.string :city
      t.integer :state_id
      t.string :country
    end
  end

  def self.down
  end
end
