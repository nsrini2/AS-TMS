class UpdateState < ActiveRecord::Migration
  def self.up
    rename_table :states, :state_provinces
  end

  def self.down
  end
end
