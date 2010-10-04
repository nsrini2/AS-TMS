class FixMessedUpTravelEmailStatusInProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :travel_email_status
    add_column :profiles, :travel_email_status, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :travel_email_status
    add_column :profiles, :travel_email_status, :integer, :default => 1
  end
end
