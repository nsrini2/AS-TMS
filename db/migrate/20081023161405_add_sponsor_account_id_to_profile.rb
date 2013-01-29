class AddSponsorAccountIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :sponsor_account_id, :integer
  end

  def self.down
    remove_column :profiles, :sponsor_account_id
  end
end
