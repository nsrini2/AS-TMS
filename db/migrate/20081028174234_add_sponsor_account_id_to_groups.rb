class AddSponsorAccountIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :sponsor_account_id, :integer
  end

  def self.down
    remove_column :groups, :sponsor_account_id
  end
end
