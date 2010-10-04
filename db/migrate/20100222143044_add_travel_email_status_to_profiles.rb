class AddTravelEmailStatusToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :travel_email_status, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :travel_email_status
  end
end
