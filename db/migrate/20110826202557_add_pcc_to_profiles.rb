class AddPccToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :pcc, :string
  end

  def self.down
    remove_column :profiles, :pcc
  end
end
