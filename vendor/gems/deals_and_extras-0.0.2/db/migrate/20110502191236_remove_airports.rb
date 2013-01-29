class RemoveAirports < ActiveRecord::Migration
  def self.up
    drop_table :airports
  end

  def self.down
  end
end
